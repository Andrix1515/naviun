import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/strings.dart';
import 'core/theme.dart';
import 'data/models/route_model.dart';
import 'features/alerts/screens/alerts_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/navigation/screens/navigation_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/record_route/screens/record_route_screen.dart';
import 'features/routes/screens/route_list_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'services/settings_service.dart';

/// Aplicación principal de Naviun.
class NaviunApp extends StatelessWidget {
  const NaviunApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      builder: (ctx, child) {
        // Aplica el multiplicador de tamaño de texto de los ajustes
        final mediaQuery = MediaQuery.of(ctx);
        final currentScaler = mediaQuery.textScaler;
        final customScaler = currentScaler.clamp(
          minScaleFactor: settings.textScaleMultiplier,
          maxScaleFactor: settings.textScaleMultiplier * 2.0,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: customScaler),
          child: child ?? const SizedBox(),
        );
      },
      home: const MainShell(),
    );
  }
}

/// Shell principal con barra de navegación inferior accesible de 4 pestañas:
/// Inicio, Rutas, Alertas, Ajustes.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _showingOnboarding = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsService>();
    if (!settings.hasSeenOnboarding) {
      _showingOnboarding = true;
    }
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openRecordRoute({RouteModel? route}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => RecordRouteScreen(initialRoute: route),
      ),
    );
  }

  void _startNavigation(RouteModel route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => NavigationScreen(route: route),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    if (!settings.hasSeenOnboarding && _showingOnboarding) {
      return OnboardingScreen(
        onComplete: () {
          setState(() {
            _showingOnboarding = false;
          });
        },
      );
    }

    final screens = [
      HomeScreen(
        onNavigateTab: _onNavigateTab,
        onOpenRecordRoute: () => _openRecordRoute(),
        onStartNavigation: _startNavigation,
      ),
      RouteListScreen(
        onStartNavigation: _startNavigation,
        onEditRoute: (route) => _openRecordRoute(route: route),
        onNewRoute: () => _openRecordRoute(),
      ),
      AlertsScreen(
        onOpenRoutesTab: () => _onNavigateTab(1),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Semantics(
        label: 'Barra de navegación principal',
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigateTab,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.navHome,
              tooltip: 'Ir a Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined),
              activeIcon: Icon(Icons.route),
              label: AppStrings.navRoutes,
              tooltip: 'Ver lista de Rutas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              activeIcon: Icon(Icons.notifications),
              label: AppStrings.navAlerts,
              tooltip: 'Ver Alertas del sistema',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: AppStrings.navSettings,
              tooltip: 'Configuración y Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
