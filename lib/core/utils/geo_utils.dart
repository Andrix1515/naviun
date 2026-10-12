import 'dart:math' as math;

/// Utilidades geográficas puras para cálculos de distancia, dispersión y formato.
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371000.0;

  /// Calcula la distancia entre dos puntos (en metros) usando la fórmula de Haversine.
  static double haversineDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final rLat1 = _degreesToRadians(lat1);
    final rLat2 = _degreesToRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Aproximación plana/equirrectangular rápida para distancias cortas (<1 km).
  static double equirectangularDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final x = _degreesToRadians(lon2 - lon1) *
        math.cos(_degreesToRadians((lat1 + lat2) / 2));
    final y = _degreesToRadians(lat2 - lat1);
    return math.sqrt(x * x + y * y) * earthRadiusMeters;
  }

  /// Convierte grados a radianes.
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Formatea una distancia en metros a texto amigable y accesible.
  static String formatDistance(double? meters) {
    if (meters == null) return 'Distancia no disponible';
    if (meters < 1.0) {
      return 'Menos de 1 metro';
    } else if (meters < 1000) {
      return '${meters.round()} metros';
    } else {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Formatea la precisión reportada por GPS.
  static String formatAccuracy(double? accuracyMeters) {
    if (accuracyMeters == null) return 'Precisión desconocida';
    return '±${accuracyMeters.toStringAsFixed(1)} m';
  }
}
