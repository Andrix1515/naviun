import 'dart:math' as math;
import '../core/constants.dart';
import '../core/utils/geo_utils.dart';
import '../data/models/capture_model.dart';

/// Resultado del procesamiento de estabilización GPS.
class StabilizationResult {
  final double? estimatedLat;
  final double? estimatedLon;
  final int validReadingsCount;
  final double averageAccuracyMeters;
  final double dispersionMeters;
  final String quality; // buena | regular | insuficiente | sin_captura
  final List<GpsReadingModel> validReadings;

  const StabilizationResult({
    this.estimatedLat,
    this.estimatedLon,
    required this.validReadingsCount,
    required this.averageAccuracyMeters,
    required this.dispersionMeters,
    required this.quality,
    required this.validReadings,
  });

  factory StabilizationResult.empty() {
    return const StabilizationResult(
      estimatedLat: null,
      estimatedLon: null,
      validReadingsCount: 0,
      averageAccuracyMeters: 0.0,
      dispersionMeters: 0.0,
      quality: GpsQuality.noCapture,
      validReadings: [],
    );
  }
}

/// Algoritmo de estabilización GPS en Dart puro (sin dependencias de Flutter UI).
///
/// Implementa filtrado de precisión, centro por mediana geográfica,
/// descarte de valores atípicos por 3x distancia mediana y cálculo de dispersión cuadrática media.
class GpsStabilizationAlgorithm {
  const GpsStabilizationAlgorithm();

  /// Procesa una lista de lecturas de GPS recolectadas durante un periodo de estabilización.
  StabilizationResult process(List<GpsReadingModel> rawReadings) {
    if (rawReadings.isEmpty) {
      return StabilizationResult.empty();
    }

    // Paso 2: Descartar lecturas con precisión reportada peor que 50 m
    final accuracyFiltered = rawReadings
        .where((r) => r.precisionM <= AppConstants.gpsMaxDiscardAccuracyMeters)
        .toList();

    if (accuracyFiltered.isEmpty) {
      return StabilizationResult(
        estimatedLat: null,
        estimatedLon: null,
        validReadingsCount: 0,
        averageAccuracyMeters: 0.0,
        dispersionMeters: 0.0,
        quality: GpsQuality.insufficient,
        validReadings: const [],
      );
    }

    // Paso 3: Calcular la mediana de latitud y longitud como centro estimado inicial
    final initialCenter = _calculateMedianCoordinates(accuracyFiltered);
    var medLat = initialCenter[0];
    var medLon = initialCenter[1];

    // Paso 4: Descartar lecturas a más de 3 veces la distancia mediana al centro y recalcular
    final distancesToInitial = accuracyFiltered.map((r) {
      return GeoUtils.haversineDistanceMeters(medLat, medLon, r.lat, r.lon);
    }).toList();

    final medianDistance = _calculateMedian(distancesToInitial);
    final outlierCutoff = AppConstants.gpsMedianDistanceMultiplier * medianDistance;

    final outlierFiltered = <GpsReadingModel>[];
    for (int i = 0; i < accuracyFiltered.length; i++) {
      // Si la distancia mediana es 0 (todas en el mismo punto), conservar todas con distancia 0
      if (medianDistance == 0.0) {
        if (distancesToInitial[i] <= 0.001) {
          outlierFiltered.add(accuracyFiltered[i]);
        }
      } else {
        if (distancesToInitial[i] <= outlierCutoff) {
          outlierFiltered.add(accuracyFiltered[i]);
        }
      }
    }

    final finalReadings = outlierFiltered.isNotEmpty ? outlierFiltered : accuracyFiltered;

    // Recalcular el centro con las lecturas válidas finales
    final finalCenter = _calculateMedianCoordinates(finalReadings);
    final finalLat = finalCenter[0];
    final finalLon = finalCenter[1];

    // Paso 5: Calcular dispersión como la raíz de la media de los cuadrados de las distancias
    final finalDistances = finalReadings.map((r) {
      return GeoUtils.haversineDistanceMeters(finalLat, finalLon, r.lat, r.lon);
    }).toList();

    double sumSquaredDistances = 0.0;
    for (final d in finalDistances) {
      sumSquaredDistances += (d * d);
    }
    final dispersion = math.sqrt(sumSquaredDistances / finalDistances.length);

    // Paso 6: Calcular la precisión media reportada
    double sumAccuracy = 0.0;
    for (final r in finalReadings) {
      sumAccuracy += r.precisionM;
    }
    final avgAccuracy = sumAccuracy / finalReadings.length;

    // Paso 7: Determinar calidad
    final quality = _determineQuality(
      dispersionMeters: dispersion,
      avgAccuracyMeters: avgAccuracy,
      validCount: finalReadings.length,
    );

    return StabilizationResult(
      estimatedLat: finalLat,
      estimatedLon: finalLon,
      validReadingsCount: finalReadings.length,
      averageAccuracyMeters: avgAccuracy,
      dispersionMeters: dispersion,
      quality: quality,
      validReadings: finalReadings,
    );
  }

  /// Calcula la mediana de latitud y longitud.
  List<double> _calculateMedianCoordinates(List<GpsReadingModel> readings) {
    final lats = readings.map((r) => r.lat).toList()..sort();
    final lons = readings.map((r) => r.lon).toList()..sort();

    final medianLat = _calculateMedian(lats);
    final medianLon = _calculateMedian(lons);
    return [medianLat, medianLon];
  }

  /// Calcula la mediana de una lista ordenada o no ordenada de números.
  double _calculateMedian(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  /// Evalúa la calidad según los umbrales definidos en [AppConstants].
  String _determineQuality({
    required double dispersionMeters,
    required double avgAccuracyMeters,
    required int validCount,
  }) {
    if (dispersionMeters <= AppConstants.qualityGoodMaxDispersionMeters &&
        avgAccuracyMeters <= AppConstants.qualityGoodMaxAvgAccuracyMeters &&
        validCount >= AppConstants.qualityGoodMinValidReadings) {
      return GpsQuality.good;
    } else if (dispersionMeters <= AppConstants.qualityRegularMaxDispersionMeters &&
        avgAccuracyMeters <= AppConstants.qualityRegularMaxAvgAccuracyMeters) {
      return GpsQuality.regular;
    } else {
      return GpsQuality.insufficient;
    }
  }
}
