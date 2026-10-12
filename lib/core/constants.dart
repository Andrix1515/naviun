import 'package:flutter/material.dart';

/// Constantes globales de Naviun.
///
/// Nota: Los umbrales de estabilización GPS y radios de proximidad
/// son valores provisionales que deben calibrarse con datos reales en el campus UNCP.
class AppConstants {
  AppConstants._();

  // Metadatos de la aplicación
  static const String appName = 'Naviun';
  static const String appSlogan = 'Tu guía en la universidad';
  static const String institutionName = 'Universidad Nacional del Centro del Perú (UNCP)';
  static const String appVersion = '1.0.0 (MVP)';

  // Texto legal y de seguridad obligatorio
  static const String safetyNotice =
      'Las rutas registradas son observaciones de un momento concreto y pueden cambiar; '
      'la app no sustituye al bastón, al perro guía ni a las técnicas de orientación y movilidad.';

  static const String testDataBadge = 'DATOS DE PRUEBA';

  // Umbral de caducidad de rutas
  static const int routeOutdatedDays = 30;

  // Umbrales de Estabilización GPS (a calibrar con datos reales en campus)
  static const double gpsMaxDiscardAccuracyMeters = 50.0;
  static const double gpsMedianDistanceMultiplier = 3.0;

  // Criterios de calidad GPS (a calibrar con datos reales)
  static const double qualityGoodMaxDispersionMeters = 5.0;
  static const double qualityGoodMaxAvgAccuracyMeters = 10.0;
  static const int qualityGoodMinValidReadings = 8;

  static const double qualityRegularMaxDispersionMeters = 15.0;
  static const double qualityRegularMaxAvgAccuracyMeters = 25.0;

  // Duraciones de estabilización seleccionables (en segundos)
  static const List<int> stabilizationDurationsSeconds = [10, 30, 60];
  static const int defaultStabilizationDurationSeconds = 30;

  // Radios de proximidad configurables (en metros)
  static const List<double> proximityRadiiMeters = [5.0, 10.0, 15.0, 20.0];
  static const double defaultProximityRadiusMeters = 10.0;

  // Umbral de precisión para considerar fiable el GPS en navegación (en metros)
  static const double maxReliableNavigationAccuracyMeters = 20.0;

  // Colores de la identidad visual UNCP (Modo claro)
  static const Color primaryGreenLight = Color(0xFF006633);
  static const Color accentGold = Color(0xFFFFCC00); // Nunca como texto en blanco
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF333333);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  // Colores (Modo oscuro)
  static const Color primaryGreenDark = Color(0xFF66CC99);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFCCCCCC);

  // Colores de estado accesible
  static const Color statusWarning = Color(0xFFD97706);
  static const Color statusError = Color(0xFFDC2626);
  static const Color statusSuccess = Color(0xFF16A34A);
  static const Color statusInfo = Color(0xFF2563EB);

  // Atribución de OpenStreetMap
  static const String osmAttribution = '© OpenStreetMap contributors';
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'com.example.naviun';
}

/// Estados de una ruta
class RouteStatus {
  static const String draft = 'borrador';
  static const String pendingValidation = 'pendiente_validacion';
  static const String verified = 'verificada';
  static const String outdated = 'desactualizada';

  static const List<String> all = [draft, pendingValidation, verified, outdated];
}

/// Tipos de punto de control
class WaypointType {
  static const String start = 'inicio';
  static const String path = 'camino';
  static const String turn = 'giro';
  static const String door = 'puerta';
  static const String stairs = 'escalera';
  static const String destination = 'destino';

  static const List<String> all = [start, path, turn, door, stairs, destination];
}

/// Calidad de captura GPS
class GpsQuality {
  static const String good = 'buena';
  static const String regular = 'regular';
  static const String insufficient = 'insuficiente';
  static const String noCapture = 'sin_captura';

  static const List<String> all = [good, regular, insufficient, noCapture];
}

/// Tipos de advertencia manual
class WarningType {
  static const String stairs = 'escalera';
  static const String ramp = 'rampa';
  static const String curb = 'bordillo';
  static const String unevenSurface = 'superficie_irregular';
  static const String door = 'puerta';
  static const String temporaryObstacle = 'obstaculo_temporal';
  static const String other = 'otro';

  static const List<String> all = [
    stairs,
    ramp,
    curb,
    unevenSurface,
    door,
    temporaryObstacle,
    other,
  ];
}
