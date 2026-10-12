import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../data/models/route_model.dart';
import '../../../data/models/waypoint_model.dart';
import '../../../data/models/warning_model.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/accessible_button.dart';
import '../../../widgets/gps_indicator.dart';

/// Pantalla Principal (Inicio) de Naviun.
class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenRecordRoute;
  final Function(RouteModel) onStartNavigation;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenRecordRoute,
    required this.onStartNavigation,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RouteModel> _routes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().checkStatus();
    });
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    final repo = context.read<RouteRepository>();
    final routes = await repo.getRoutes();
    if (mounted) {
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleTestRoute() async {
    final repo = context.read<RouteRepository>();
    final completeTestRoute = RouteModel(
      nombre: 'Demostración UNCP: Pabellón A a Cafetería',
      origen: 'Acceso Principal Pabellón A',
      destino: 'Cafetería Central',
      estado: RouteStatus.verified,
      esDatoDePrueba: true,
      creadaEn: DateTime.now().toIso8601String(),
      ultimaRevision: DateTime.now().toIso8601String(),
      puntos: [
        WaypointModel(
          orden: 1,
          nombre: 'Puerta Principal Pabellón A',
          tipo: WaypointType.start,
          instruccion: 'Sal por la puerta doble. Avanza 10 pasos en línea recta sobre la baldosa podotáctil.',
        ),
        WaypointModel(
          orden: 2,
          nombre: 'Giro hacia el patio central',
          tipo: WaypointType.turn,
          instruccion: 'Gira 90 grados a tu derecha. Camina 25 metros hasta escuchar la fuente de agua.',
          advertencias: [
            WarningModel(
              tipo: WarningType.unevenSurface,
              nota: 'Jardín con borde de adoquines a tu izquierda.',
              fechaObservacion: DateTime.now().toIso8601String(),
              temporal: false,
              estadoRevision: 'revisada',
            ),
          ],
        ),
        WaypointModel(
          orden: 3,
          nombre: 'Rampa de acceso a Cafetería',
          tipo: WaypointType.path,
          instruccion: 'Sube por la rampa de concreto con barandilla metálica a la derecha durante 8 metros.',
          advertencias: [
            WarningModel(
              tipo: WarningType.ramp,
              nota: 'Rampa con leve inclinación y piso antideslizante.',
              fechaObservacion: DateTime.now().toIso8601String(),
              temporal: false,
              estadoRevision: 'revisada',
            ),
          ],
        ),
        WaypointModel(
          orden: 4,
          nombre: 'Puerta de la Cafetería Central',
          tipo: WaypointType.destination,
          instruccion: 'Has llegado a la entrada principal de la Cafetería. La puerta abre hacia afuera.',
        ),
      ],
    );

    await repo.saveRoute(completeTestRoute);
    await _loadRoutes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.testRouteCreatedSuccess),
          backgroundColor: AppConstants.primaryGreenLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();
    final settings = context.watch<SettingsService>();
    final tts = context.watch<TtsService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icono_Naviun.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.navigation, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(AppStrings.appName),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await location.checkStatus();
            await _loadRoutes();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo accesible
                Text(
                  AppStrings.homeGreeting,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.universityName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : AppConstants.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Indicador de GPS
                GpsIndicator(
                  status: location.status,
                  position: location.currentPosition,
                  onSettingsPressed: () async {
                    if (location.status == LocationStatus.serviceDisabled) {
                      await location.openLocationSettings();
                    } else {
                      await location.requestPermission();
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Indicador de Voz TTS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: settings.ttsVoiceEnabled
                          ? (isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight)
                          : Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        settings.ttsVoiceEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                        color: settings.ttsVoiceEnabled
                            ? (isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight)
                            : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          settings.ttsVoiceEnabled
                              ? 'Voz activa (${tts.selectedLanguage})'
                              : 'Voz desactivada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppConstants.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Botones Principales Grandes
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),

                // Botón Iniciar Navegación
                AccessibleButton(
                  label: AppStrings.homeStartNavigation,
                  icon: Icons.navigation_rounded,
                  type: AccessibleButtonType.primary,
                  minHeight: 64,
                  semanticHint: 'Muestra la lista de rutas registradas para comenzar a navegar',
                  onPressed: () {
                    // Pestaña Rutas (índice 1)
                    widget.onNavigateTab(1);
                  },
                ),
                const SizedBox(height: 14),

                // Botón Registrar Ruta
                AccessibleButton(
                  label: AppStrings.homeRecordRoute,
                  icon: Icons.add_location_alt_rounded,
                  type: AccessibleButtonType.secondary,
                  minHeight: 56,
                  semanticHint: 'Abre el asistente para crear y registrar una nueva ruta con puntos de control',
                  onPressed: widget.onOpenRecordRoute,
                ),
                const SizedBox(height: 14),

                // Botón Buscar Ruta
                AccessibleButton(
                  label: AppStrings.homeSearchRoute,
                  icon: Icons.search,
                  type: AccessibleButtonType.secondary,
                  minHeight: 56,
                  semanticHint: 'Busca una ruta guardada por nombre o destino',
                  onPressed: () {
                    widget.onNavigateTab(1);
                  },
                ),
                const SizedBox(height: 28),

                // Sección Estado de Rutas
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_routes.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.homeNoRoutesTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.homeNoRoutesSubtitle,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: isDark ? Colors.grey[300] : AppConstants.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AccessibleButton(
                          label: AppStrings.homeCreateTestRoute,
                          icon: Icons.science_outlined,
                          type: AccessibleButtonType.gold,
                          onPressed: _createSampleTestRoute,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rutas disponibles (${_routes.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateTab(1),
                        child: const Text('Ver todas', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Muestra la ruta más reciente
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _routes.first.nombre,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_routes.first.esDatoDePrueba)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppConstants.accentGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRUEBA',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${_routes.first.origen} → ${_routes.first.destino}'),
                          const SizedBox(height: 12),
                          AccessibleButton(
                            label: AppStrings.routeStartButton,
                            icon: Icons.play_arrow,
                            minHeight: 48,
                            onPressed: () => widget.onStartNavigation(_routes.first),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
