import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/local_json_route_repository.dart';
import 'data/repositories/route_repository.dart';
import 'services/haptic_service.dart';
import 'services/inertial_sensor_service.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'services/tts_service.dart';
import 'services/voice_command_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar preferencias locales persistentes
  final sharedPreferences = await SharedPreferences.getInstance();
  final settingsService = SettingsService(sharedPreferences);

  // Instanciar repositorios y servicios
  final routeRepository = LocalJsonRouteRepository();
  final locationService = LocationService();
  final ttsService = TtsService();
  final hapticService = HapticService();
  final inertialSensorService = InertialSensorService();
  final voiceCommandService = VoiceCommandService();

  // Inicializar servicio de voz en segundo plano
  await ttsService.init();
  await voiceCommandService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider<LocationService>.value(value: locationService),
        ChangeNotifierProvider<TtsService>.value(value: ttsService),
        Provider<HapticService>.value(value: hapticService),
        ChangeNotifierProvider<InertialSensorService>.value(value: inertialSensorService),
        Provider<VoiceCommandService>.value(value: voiceCommandService),
        Provider<RouteRepository>.value(value: routeRepository),
      ],
      child: const NaviunApp(),
    ),
  );
}
