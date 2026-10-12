import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils', () {
    test('calcula distancia Haversine entre dos puntos conocidos', () {
      // Coordenadas en Campus UNCP (Entrada Mariscal Castilla y Pabellón Central)
      const lat1 = -12.056388;
      const lon1 = -75.218888;
      const lat2 = -12.057388;
      const lon2 = -75.218888;

      final dist = GeoUtils.haversineDistanceMeters(lat1, lon1, lat2, lon2);
      // 0.001 grado de latitud es ~111 metros
      expect(dist, closeTo(111.0, 5.0));
    });

    test('distancia a sí mismo es cero', () {
      final dist = GeoUtils.haversineDistanceMeters(-12.056, -75.218, -12.056, -75.218);
      expect(dist, equals(0.0));
    });

    test('formatea distancias amigablemente para accesibilidad', () {
      expect(GeoUtils.formatDistance(null), equals('Distancia no disponible'));
      expect(GeoUtils.formatDistance(0.5), equals('Menos de 1 metro'));
      expect(GeoUtils.formatDistance(12.4), equals('12 metros'));
      expect(GeoUtils.formatDistance(1250.0), equals('1.3 km'));
    });

    test('formatea precisión amigablemente', () {
      expect(GeoUtils.formatAccuracy(null), equals('Precisión desconocida'));
      expect(GeoUtils.formatAccuracy(4.56), equals('±4.6 m'));
    });
  });
}
