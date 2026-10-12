import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naviun/app.dart';
import 'package:naviun/data/repositories/local_json_route_repository.dart';
import 'package:naviun/data/repositories/route_repository.dart';
import 'package:naviun/services/location_service.dart';
import 'package:naviun/services/settings_service.dart';
import 'package:naviun/services/tts_service.dart';

void main() {
  testWidgets('NaviunApp arranca correctamente en pantalla de Inicio', (tester) async {
    SharedPreferences.setMockInitialValues({'settings_has_seen_onboarding': true});
    final prefs = await SharedPreferences.getInstance();
    final settingsService = SettingsService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<LocationService>.value(value: LocationService()),
          ChangeNotifierProvider<TtsService>.value(value: TtsService()),
          Provider<RouteRepository>.value(value: LocalJsonRouteRepository()),
        ],
        child: const NaviunApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Naviun'), findsOneWidget);
    expect(find.text('Iniciar navegación'), findsOneWidget);
    expect(find.text('Registrar ruta'), findsOneWidget);
  });
}
