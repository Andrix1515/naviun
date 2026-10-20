import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/inertial_constants.dart';
import '../../../core/strings.dart';
import '../../../data/models/route_model.dart';
import '../../../data/models/warning_model.dart';
import '../../../data/models/waypoint_model.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/inertial_sensor_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/accessible_button.dart';

/// Pantalla de Ajustes y accesibilidad de Naviun.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _createTestRoute(BuildContext context) async {
    final repo = context.read<RouteRepository>();
    final testRoute = RouteModel(
      nombre: 'Ruta de Demostración UNCP (Aula 101 a Salida)',
      origen: 'Aula 101 Pabellón de Contabilidad',
      destino: 'Puerta Peatonal Lateral',
      estado: RouteStatus.verified,
      esDatoDePrueba: true,
      creadaEn: DateTime.now().toIso8601String(),
      ultimaRevision: DateTime.now().toIso8601String(),
      puntos: [
        WaypointModel(
          orden: 1,
          nombre: 'Puerta del Aula 101',
          tipo: WaypointType.start,
          instruccion: 'Sal al pasillo y gira hacia la izquierda. Avanza 12 metros tocando la pared con tu bastón.',
        ),
        WaypointModel(
          orden: 2,
          nombre: 'Giro hacia el pabellón central',
          tipo: WaypointType.turn,
          instruccion:
              'Gira 90 grados a tu derecha. Camina 15 metros en línea recta.',
          advertencias: [
            WarningModel(
              tipo: WarningType.door,
              nota: 'Puerta vaivén cortafuegos en el trayecto.',
              fechaObservacion: DateTime.now().toIso8601String(),
              temporal: false,
              estadoRevision: 'revisada',
            ),
          ],
        ),
        WaypointModel(
          orden: 3,
          nombre: 'Escaleras de bajada',
          tipo: WaypointType.stairs,
          instruccion: 'Baja las escaleras de 6 peldaños sujetando el pasamano del lado derecho.',
          advertencias: [
            WarningModel(
              tipo: WarningType.stairs,
              nota:
                  'Escalera de 6 gradas con cinta táctil de alerta al inicio.',
              fechaObservacion: DateTime.now().toIso8601String(),
              temporal: false,
              estadoRevision: 'revisada',
            ),
          ],
        ),
        WaypointModel(
          orden: 4,
          nombre: 'Puerta Peatonal Lateral',
          tipo: WaypointType.destination,
          instruccion:
              'Has llegado a la puerta peatonal lateral de salida al campus.',
        ),
      ],
    );

    await repo.saveRoute(testRoute);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.testRouteCreatedSuccess),
          backgroundColor: AppConstants.primaryGreenLight,
        ),
      );
    }
  }

  Future<void> _calibrateStepLength(BuildContext context) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _StepCalibrationDialog(
        sensorService: context.read<InertialSensorService>(),
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await context.read<SettingsService>().setCalibratedStepLengthMeters(result);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calibración guardada: paso medio aproximado de '
          '${result.toStringAsFixed(2)} m.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final location = context.watch<LocationService>();
    final inertial = context.watch<InertialSensorService>();
    final tts = context.read<TtsService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Accesibilidad y Visualización
              _buildSectionTitle(
                context,
                AppStrings.settingsSectionAccessibility,
              ),
              const SizedBox(height: 12),

              // Selector de Tamaño de Texto
              Text(
                AppStrings.welcomeTextSizeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment(
                    value: 1.0,
                    label: Text(AppStrings.textSizeNormal),
                  ),
                  ButtonSegment(
                    value: 1.15,
                    label: Text(AppStrings.textSizeLarge),
                  ),
                  ButtonSegment(
                    value: 1.30,
                    label: Text(AppStrings.textSizeExtraLarge),
                  ),
                ],
                selected: {settings.textScaleMultiplier},
                onSelectionChanged: (val) =>
                    settings.setTextScaleMultiplier(val.first),
              ),
              const SizedBox(height: 20),

              // Selector de Modo Claro / Oscuro
              Text(
                AppStrings.welcomeThemeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                  ),
                  ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (val) => settings.setThemeMode(val.first),
              ),
              const SizedBox(height: 28),

              // 2. Voz y Audio
              _buildSectionTitle(context, AppStrings.settingsSectionVoice),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  AppStrings.voiceEnabledLabel,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: settings.ttsVoiceEnabled,
                onChanged: (val) => settings.setTtsVoiceEnabled(val),
              ),
              const SizedBox(height: 8),

              Text(
                '${AppStrings.voiceRateLabel}: ${(settings.ttsRate * 2).toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: settings.ttsRate,
                min: 0.3,
                max: 0.9,
                divisions: 6,
                onChanged: (val) => settings.setTtsRate(val),
              ),
              const SizedBox(height: 8),

              Text(
                '${AppStrings.voiceVolumeLabel}: ${(settings.ttsVolume * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: settings.ttsVolume,
                min: 0.2,
                max: 1.0,
                divisions: 8,
                onChanged: (val) => settings.setTtsVolume(val),
              ),
              const SizedBox(height: 10),

              AccessibleButton(
                label: AppStrings.testVoiceButton,
                icon: Icons.volume_up,
                type: AccessibleButtonType.secondary,
                minHeight: 48,
                onPressed: () => tts.testVoice(
                  rate: settings.ttsRate,
                  volume: settings.ttsVolume,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'naviun',
                    label: Text('Voz propia de Naviun'),
                  ),
                  ButtonSegment(
                    value: 'screenreader',
                    label: Text('Lector de pantalla'),
                  ),
                ],
                selected: {settings.announcementMode},
                onSelectionChanged: (val) =>
                    settings.setAnnouncementMode(val.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Comandos por voz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: settings.voiceCommandEnabled,
                onChanged: (val) => settings.setVoiceCommandEnabled(val),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  AppStrings.vibrationEnabledLabel,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: settings.vibrationEnabled,
                onChanged: (val) => settings.setVibrationEnabled(val),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'baja', label: Text('Baja')),
                  ButtonSegment(value: 'media', label: Text('Media')),
                  ButtonSegment(value: 'alta', label: Text('Alta')),
                ],
                selected: {settings.hapticIntensity},
                onSelectionChanged: (val) =>
                    settings.setHapticIntensity(val.first),
              ),
              const SizedBox(height: 28),

              // 3. Navegación y Seguridad
              _buildSectionTitle(context, AppStrings.settingsSectionNavigation),
              const SizedBox(height: 12),

              Text(
                '${AppStrings.proximityRadiusLabel} (${settings.proximityRadius.toInt()} m)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<double>(
                segments: AppConstants.proximityRadiiMeters
                    .map(
                      (r) => ButtonSegment(
                        value: r,
                        label: Text('${r.toInt()} m'),
                      ),
                    )
                    .toList(),
                selected: {settings.proximityRadius},
                onSelectionChanged: (val) =>
                    settings.setProximityRadius(val.first),
              ),
              const SizedBox(height: 20),

              Text(
                AppStrings.emergencyContactLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: settings.emergencyContact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: AppStrings.emergencyContactHint,
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (val) => settings.setEmergencyContact(val),
              ),
              const SizedBox(height: 28),

              // 4. Sensores y Permisos
              _buildSectionTitle(context, AppStrings.settingsSectionSensors),
              const SizedBox(height: 12),

              _buildSensorTile(
                title: AppStrings.sensorGpsLabel,
                subtitle: location.status == LocationStatus.ready
                    ? 'Activo y disponible'
                    : 'Requiere atención o permisos',
                isActive: location.status == LocationStatus.ready,
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Estimación por sensores (experimental)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Usa acelerómetro y giroscopio reales para estimar pasos y giros relativos. '
                  'No confirma llegadas ni sustituye el GPS o la guía manual.',
                ),
                value: settings.inertialDemoEnabled,
                onChanged: settings.setInertialDemoEnabled,
              ),
              if (settings.inertialDemoEnabled) ...[
                _buildSensorTile(
                  title: 'Acelerómetro y giroscopio',
                  subtitle:
                      inertial.sensorError ??
                      (inertial.isAvailable
                          ? 'Recibiendo datos reales del dispositivo'
                          : inertial.isActive
                          ? 'Esperando datos del sensor'
                          : 'Listos para la siguiente navegación'),
                  isActive: inertial.isAvailable,
                ),
                const SizedBox(height: 8),
                Text(
                  settings.calibratedStepLengthMeters == null
                      ? 'Longitud de paso: sin calibrar '
                            '(valor provisional: ${InertialConstants.defaultStepLengthMeters.toStringAsFixed(2)} m)'
                      : 'Longitud de paso calibrada: '
                            '${settings.calibratedStepLengthMeters!.toStringAsFixed(2)} m',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                AccessibleButton(
                  label: 'Calibrar paso caminando 10 metros',
                  icon: Icons.directions_walk,
                  type: AccessibleButtonType.secondary,
                  onPressed: () => _calibrateStepLength(context),
                ),
              ],
              const SizedBox(height: 6),
              _buildSensorTile(
                title: AppStrings.sensorBarometer,
                subtitle: AppStrings.sensorNotIncluded,
                isActive: false,
              ),
              const SizedBox(height: 6),
              _buildSensorTile(
                title: AppStrings.sensorBeacons,
                subtitle: AppStrings.sensorNotIncluded,
                isActive: false,
              ),
              const SizedBox(height: 6),
              _buildSensorTile(
                title: AppStrings.sensorComputerVision,
                subtitle: AppStrings.sensorNotIncluded,
                isActive: false,
              ),
              const SizedBox(height: 16),

              AccessibleButton(
                label: 'Abrir Permisos en Ajustes de Android',
                icon: Icons.settings,
                type: AccessibleButtonType.secondary,
                minHeight: 48,
                onPressed: () => location.openAppSettings(),
              ),
              const SizedBox(height: 28),

              // 5. Gestión de Datos y Prueba
              _buildSectionTitle(context, AppStrings.settingsSectionData),
              const SizedBox(height: 12),
              AccessibleButton(
                label: AppStrings.createTestRouteButton,
                icon: Icons.science_outlined,
                type: AccessibleButtonType.gold,
                minHeight: 52,
                semanticHint: 'Genera una ruta de prueba sin coordenadas para practicar en interiores',
                onPressed: () => _createTestRoute(context),
              ),
              const SizedBox(height: 28),

              // 6. Información y Aviso Legal Obligatorio
              _buildSectionTitle(context, AppStrings.settingsSectionAbout),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF94A3B8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '${AppStrings.appName} - ${AppConstants.appSlogan}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      AppConstants.institutionName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aviso de Seguridad:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.safetyNotice,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: isDark
                            ? Colors.grey[300]
                            : AppConstants.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppConstants.primaryGreenLight),
        ),
        const Divider(thickness: 1.5),
      ],
    );
  }

  Widget _buildSensorTile({
    required String title,
    required String subtitle,
    required bool isActive,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(
          isActive ? Icons.check_circle : Icons.do_not_disturb_on_outlined,
          color: isActive ? AppConstants.statusSuccess : Colors.grey,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _StepCalibrationDialog extends StatefulWidget {
  const _StepCalibrationDialog({required this.sensorService});

  final InertialSensorService sensorService;

  @override
  State<_StepCalibrationDialog> createState() => _StepCalibrationDialogState();
}

class _StepCalibrationDialogState extends State<_StepCalibrationDialog> {
  final _distanceController = TextEditingController(text: '10');
  String? _error;

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorService = widget.sensorService;
    return AnimatedBuilder(
      animation: sensorService,
      builder: (context, _) {
        return AlertDialog(
          title: const Text('Calibrar longitud de paso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Camina una distancia medida, con el teléfono en la posición en que '
                'lo llevarás durante la prueba. La calibración usa solo las lecturas '
                'reales del acelerómetro.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _distanceController,
                enabled: !sensorService.isCalibrating,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Distancia conocida en metros',
                  suffixText: 'm',
                ),
              ),
              if (sensorService.isCalibrating) ...[
                const SizedBox(height: 16),
                Text(
                  'Pasos detectados: ${sensorService.steps}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Camina ahora; al terminar, pulsa Finalizar calibración.',
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (sensorService.isCalibrating) {
                  sensorService.cancelStepCalibration();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            if (!sensorService.isCalibrating)
              FilledButton(
                onPressed: () async {
                  final distance = double.tryParse(
                    _distanceController.text.trim().replaceAll(',', '.'),
                  );
                  if (distance == null || !distance.isFinite || distance < 2) {
                    setState(() {
                      _error =
                          'Ingresa una distancia válida de al menos 2 metros.';
                    });
                    return;
                  }
                  setState(() => _error = null);
                  await sensorService.beginStepCalibration();
                },
                child: const Text('Iniciar caminata'),
              )
            else
              FilledButton(
                onPressed: () async {
                  final distance = double.parse(
                    _distanceController.text.trim().replaceAll(',', '.'),
                  );
                  final stepLength = sensorService.finishStepCalibration(
                    distance,
                  );
                  if (stepLength == null ||
                      stepLength < 0.2 ||
                      stepLength > 1.5) {
                    await sensorService.stopTracking();
                    if (!context.mounted) {
                      return;
                    }
                    setState(() {
                      _error = stepLength == null
                          ? 'No se detectaron pasos. Reintenta en un lugar seguro.'
                          : 'El paso calculado no parece válido. Repite la medición.';
                    });
                    return;
                  }
                  await sensorService.stopTracking();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop(stepLength);
                },
                child: const Text('Finalizar calibración'),
              ),
          ],
        );
      },
    );
  }
}
