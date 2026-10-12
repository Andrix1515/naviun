import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/core/constants.dart';
import 'package:naviun/data/models/capture_model.dart';
import 'package:naviun/services/stabilization.dart';

void main() {
  group('GpsStabilizationAlgorithm', () {
    const algorithm = GpsStabilizationAlgorithm();

    test('retorna sin_captura para lista vacía', () {
      final result = algorithm.process([]);
      expect(result.quality, equals(GpsQuality.noCapture));
      expect(result.validReadingsCount, equals(0));
      expect(result.estimatedLat, isNull);
      expect(result.estimatedLon, isNull);
    });

    test('descarta lecturas con precisión peor a 50m y marca insuficiente si no quedan válidas', () {
      final readings = [
        GpsReadingModel(lat: -12.0560, lon: -75.2180, precisionM: 55.0, timestamp: '2026-10-10T10:00:00Z'),
        GpsReadingModel(lat: -12.0561, lon: -75.2181, precisionM: 70.0, timestamp: '2026-10-10T10:00:01Z'),
      ];
      final result = algorithm.process(readings);
      expect(result.quality, equals(GpsQuality.insufficient));
      expect(result.validReadingsCount, equals(0));
      expect(result.estimatedLat, isNull);
    });

    test('clasifica como buena con >=8 lecturas, precisión media <=10m y dispersión <=5m', () {
      // Coordenadas UNCP (Huancayo, Perú) ~ -12.0563, -75.2188
      final readings = List.generate(10, (i) {
        return GpsReadingModel(
          lat: -12.056300 + (i * 0.00001), // desplazamiento mínimo (~1 metro)
          lon: -75.218800 + (i * 0.00001),
          precisionM: 4.5,
          timestamp: '2026-10-10T10:00:0${i}Z',
        );
      });

      final result = algorithm.process(readings);
      expect(result.validReadingsCount, equals(10));
      expect(result.quality, equals(GpsQuality.good));
      expect(result.averageAccuracyMeters, closeTo(4.5, 0.1));
      expect(result.dispersionMeters, lessThanOrEqualTo(5.0));
      expect(result.estimatedLat, isNotNull);
      expect(result.estimatedLon, isNotNull);
    });

    test('descarta valores atípicos severos (outliers) mediante 3x mediana de distancia', () {
      // 9 lecturas concentradas en el punto objetivo + 1 lectura anómala a 500m
      final readings = List.generate(9, (i) {
        return GpsReadingModel(
          lat: -12.056300,
          lon: -75.218800,
          precisionM: 5.0,
          timestamp: '2026-10-10T10:00:0${i}Z',
        );
      });
      // Outlier a distancia grande pero con precisión supuestamente buena de 10m
      readings.add(
        GpsReadingModel(
          lat: -12.050000, // ~700m de distancia
          lon: -75.218800,
          precisionM: 10.0,
          timestamp: '2026-10-10T10:00:10Z',
        ),
      );

      final result = algorithm.process(readings);
      // El outlier debió ser filtrado
      expect(result.validReadingsCount, equals(9));
      expect(result.estimatedLat, closeTo(-12.056300, 0.0001));
    });

    test('clasifica como regular cuando dispersión está entre 5 y 15m o precisión media entre 10 y 25m', () {
      final readings = List.generate(6, (i) {
        return GpsReadingModel(
          lat: -12.056300 + (i * 0.00005), // ~5-6 metros entre lecturas
          lon: -75.218800,
          precisionM: 15.0,
          timestamp: '2026-10-10T10:00:0${i}Z',
        );
      });

      final result = algorithm.process(readings);
      expect(result.quality, equals(GpsQuality.regular));
    });
  });
}
