import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../data/models/route_model.dart';
import '../../../services/location_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/accessible_button.dart';
import '../../../widgets/accessible_dialog.dart';
import '../../../widgets/gps_indicator.dart';
import '../../../widgets/instruction_panel.dart';
import '../../../widgets/warning_card.dart';

/// Pantalla prioritaria de Seguimiento de Ruta para personas con discapacidad visual.
class NavigationScreen extends StatefulWidget {
  final RouteModel route;

  const NavigationScreen({super.key, required this.route});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Seguimiento de aviso de proximidad emitido por punto
  final Set<int> _announcedProximityIndices = {};
  bool _hasAnnouncedGpsUnreliable = false;

  StreamSubscription<Position>? _positionSubscription;
  Position? _latestPosition;

  @override
  void initState() {
    super.initState();
    // Mantener la pantalla encendida durante la navegación activa
    WakelockPlus.enable();

    // Iniciar rastreo de GPS y locución inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGpsTracking();
      _announceCurrentWaypoint(isInitial: true);
    });
  }

  @override
  void dispose() {
    // Desactivar bloqueo de pantalla y suscripción de GPS
    WakelockPlus.disable();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _startGpsTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        _latestPosition = position;
      });

      _checkProximityAlert(position);
    });
  }

  /// Comprueba si el usuario se encuentra dentro del radio de proximidad del punto actual.
  void _checkProximityAlert(Position userPos) {
    if (_isPaused || _isCompleted) return;
    if (_currentIndex >= widget.route.puntos.length) return;

    final targetWp = widget.route.puntos[_currentIndex];
    if (!targetWp.hasCoordinates) return;

    final settings = context.read<SettingsService>();
    final accuracy = userPos.accuracy;

    // Solo se emite si la precisión es suficiente
    if (accuracy > AppConstants.maxReliableNavigationAccuracyMeters) {
      if (!_hasAnnouncedGpsUnreliable && accuracy > 35.0) {
        _hasAnnouncedGpsUnreliable = true;
        _speakText(AppStrings.speechGpsUnreliable);
      }
      return;
    } else {
      _hasAnnouncedGpsUnreliable = false;
    }

    final distance = GeoUtils.haversineDistanceMeters(
      userPos.latitude,
      userPos.longitude,
      targetWp.latitud!,
      targetWp.longitud!,
    );

    // Verificar radio configurable (por defecto 10 m)
    final radius = settings.proximityRadius;
    if (distance <= radius && !_announcedProximityIndices.contains(_currentIndex)) {
      _announcedProximityIndices.add(_currentIndex);

      final msg = AppStrings.proximityNotice.replaceAll('{point}', targetWp.nombre);
      _speakText(msg);

      if (settings.vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  double? _calculateDistanceToCurrent() {
    if (_latestPosition == null) return null;
    if (_currentIndex >= widget.route.puntos.length) return null;
    final wp = widget.route.puntos[_currentIndex];
    if (!wp.hasCoordinates) return null;

    return GeoUtils.haversineDistanceMeters(
      _latestPosition!.latitude,
      _latestPosition!.longitude,
      wp.latitud!,
      wp.longitud!,
    );
  }

  /// Anuncia las advertencias registradas (si existen) y luego la instrucción del tramo.
  Future<void> _announceCurrentWaypoint({bool isInitial = false}) async {
    if (_currentIndex >= widget.route.puntos.length) return;

    final wp = widget.route.puntos[_currentIndex];
    final buffer = StringBuffer();

    if (isInitial) {
      buffer.write('Iniciando ruta ${widget.route.nombre}. ');
      if (widget.route.esDatoDePrueba) {
        buffer.write('Atención, esta es una ruta con datos de prueba. ');
      }
      buffer.write('Primer punto: ${wp.nombre}. ');
    } else {
      buffer.write('Punto ${_currentIndex + 1} de ${widget.route.puntos.length}: ${wp.nombre}. ');
    }

    // 1. Advertencias primero, con su fecha de observación
    if (wp.advertencias.isNotEmpty) {
      for (final warn in wp.advertencias) {
        final date = AppDateUtils.parseIso(warn.fechaObservacion);
        final dateStr = AppDateUtils.formatReadableDate(date);
        final warnSpeech = AppStrings.speechWarningPrefix
            .replaceAll('{date}', dateStr)
            .replaceAll('{type}', _getWarningTypeSpeech(warn.tipo))
            .replaceAll('{note}', warn.nota);
        buffer.write('$warnSpeech ');
      }
    }

    // 2. Instrucción del tramo
    buffer.write(wp.instruccion);

    await _speakText(buffer.toString());
  }

  String _getWarningTypeSpeech(String tipo) {
    switch (tipo) {
      case WarningType.stairs:
        return 'Escalera';
      case WarningType.ramp:
        return 'Rampa';
      case WarningType.curb:
        return 'Bordillo o desnivel';
      case WarningType.unevenSurface:
        return 'Superficie irregular';
      case WarningType.door:
        return 'Puerta o acceso';
      case WarningType.temporaryObstacle:
        return 'Obstáculo temporal';
      default:
        return 'Precaución en el entorno';
    }
  }

  Future<void> _speakText(String text) async {
    final tts = context.read<TtsService>();
    final settings = context.read<SettingsService>();
    await tts.speak(
      text,
      rate: settings.ttsRate,
      volume: settings.ttsVolume,
      enabled: settings.ttsVoiceEnabled,
    );
  }

  /// Acción principal: El usuario confirma manualmente la llegada al punto.
  void _onReachedPoint() {
    if (_isPaused || _isCompleted) return;

    final settings = context.read<SettingsService>();
    if (settings.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= widget.route.puntos.length) {
      // Fin de la ruta alcanzado
      setState(() {
        _isCompleted = true;
      });
      _speakText(AppStrings.speechRouteFinished);
    } else {
      setState(() {
        _currentIndex = nextIndex;
      });
      _announceCurrentWaypoint();
    }
  }

  /// Repite la instrucción y advertencias actuales
  void _repeatInstruction() {
    _announceCurrentWaypoint();
  }

  /// Alterna entre pausar y reanudar la navegación
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _speakText(AppStrings.navigationPausedTitle);
    } else {
      _speakText('Reanudando navegación.');
      _announceCurrentWaypoint();
    }
  }

  /// Botón "Necesito ayuda"
  Future<void> _needHelp() async {
    setState(() {
      _isPaused = true;
    });

    final settings = context.read<SettingsService>();
    await _speakText(AppStrings.speechNeedHelp);

    if (!mounted) return;

    final contact = settings.emergencyContact;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_center, color: AppConstants.statusError, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Asistencia de seguridad',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Detente en un lugar seguro. Si no puedes continuar de forma autónoma, solicita apoyo a una persona cercana en el campus.',
                style: TextStyle(fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 20),
              if (contact.isNotEmpty) ...[
                AccessibleButton(
                  label: '${AppStrings.emergencyContactCall} ($contact)',
                  icon: Icons.phone,
                  type: AccessibleButtonType.danger,
                  onPressed: () async {
                    final uri = Uri.parse('tel:$contact');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              AccessibleButton(
                label: 'Cerrar y Reanudar Navegación',
                type: AccessibleButtonType.primary,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _togglePause();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Finalizar ruta antes de tiempo con confirmación
  Future<void> _exitNavigation() async {
    final confirmed = await AccessibleConfirmDialog.show(
      context,
      title: AppStrings.exitNavConfirmTitle,
      message: AppStrings.exitNavConfirmMessage,
      confirmLabel: 'Finalizar',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isCompleted) {
      return _buildCompletedView(isDark);
    }

    final currentWaypoint = widget.route.puntos[_currentIndex];
    final distanceMeters = _calculateDistanceToCurrent();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 28),
            tooltip: AppStrings.btnExitNavigation,
            onPressed: _exitNavigation,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado del GPS en cabecera
              GpsIndicator(
                status: location.status,
                position: _latestPosition,
              ),
              const SizedBox(height: 10),

              // Banner si la navegación está pausada
              if (_isPaused)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppConstants.accentGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.pause_circle_filled, color: Colors.black, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Navegación en pausa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Panel Central de Alto Contraste con Instrucción Activa
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InstructionPanel(
                        currentWaypoint: currentWaypoint,
                        currentIndex: _currentIndex,
                        totalWaypoints: widget.route.puntos.length,
                        distanceMeters: distanceMeters,
                        currentGpsAccuracy: _latestPosition?.accuracy,
                      ),
                      const SizedBox(height: 12),

                      // Advertencias activas en este tramo
                      if (currentWaypoint.advertencias.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Advertencias en este tramo:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...currentWaypoint.advertencias.map(
                              (warn) => WarningCard(warning: warn),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botones de acción accesibles
              // 1. Botón GIGANTE "Llegué al punto"
              AccessibleButton(
                label: AppStrings.btnPointReached,
                icon: Icons.check_circle,
                type: AccessibleButtonType.primary,
                minHeight: 68,
                semanticHint: 'Confirma manualmente que llegaste a este punto y anuncia la siguiente instrucción',
                onPressed: _isPaused ? null : _onReachedPoint,
              ),
              const SizedBox(height: 10),

              // 2. Fila con "Repetir" y "Pausar / Reanudar"
              Row(
                children: [
                  Expanded(
                    child: AccessibleButton(
                      label: AppStrings.btnRepeatInstruction,
                      icon: Icons.replay,
                      type: AccessibleButtonType.secondary,
                      minHeight: 52,
                      onPressed: _repeatInstruction,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AccessibleButton(
                      label: _isPaused ? AppStrings.btnResumeNavigation : AppStrings.btnPauseNavigation,
                      icon: _isPaused ? Icons.play_arrow : Icons.pause,
                      type: AccessibleButtonType.secondary,
                      minHeight: 52,
                      onPressed: _togglePause,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. Botón "Necesito ayuda"
              AccessibleButton(
                label: AppStrings.btnNeedHelp,
                icon: Icons.emergency,
                type: AccessibleButtonType.danger,
                minHeight: 52,
                semanticHint: 'Pausa la navegación y ofrece asistencia de seguridad o llamada de ayuda',
                onPressed: _needHelp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedView(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta completada'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.task_alt,
                color: AppConstants.statusSuccess,
                size: 96,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.speechRouteFinished,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Llegaste al punto final: ${widget.route.destino}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 48),
              AccessibleButton(
                label: 'Volver a Rutas',
                icon: Icons.arrow_back,
                type: AccessibleButtonType.primary,
                minHeight: 56,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
