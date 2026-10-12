/// Lectura individual de GPS recolectada durante la fase de estabilización.
class GpsReadingModel {
  final double lat;
  final double lon;
  final double precisionM;
  final String timestamp; // ISO8601

  GpsReadingModel({
    required this.lat,
    required this.lon,
    required this.precisionM,
    required this.timestamp,
  });

  factory GpsReadingModel.fromJson(Map<String, dynamic> json) {
    return GpsReadingModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      precisionM: (json['precision_m'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'precision_m': precisionM,
      'timestamp': timestamp,
    };
  }
}

/// Registro completo de captura y estabilización de un punto.
class CaptureModel {
  final int duracionS;
  final List<GpsReadingModel> lecturas;
  final int lecturasValidas;
  final double precisionMediaM;
  final double dispersionM;
  final String calidad; // buena | regular | insuficiente | sin_captura

  CaptureModel({
    this.duracionS = 30,
    this.lecturas = const [],
    this.lecturasValidas = 0,
    this.precisionMediaM = 0.0,
    this.dispersionM = 0.0,
    this.calidad = 'sin_captura',
  });

  factory CaptureModel.empty() {
    return CaptureModel(
      duracionS: 30,
      lecturas: const [],
      lecturasValidas: 0,
      precisionMediaM: 0.0,
      dispersionM: 0.0,
      calidad: 'sin_captura',
    );
  }

  factory CaptureModel.fromJson(Map<String, dynamic> json) {
    final rawLecturas = json['lecturas'] as List<dynamic>? ?? [];
    return CaptureModel(
      duracionS: json['duracion_s'] as int? ?? 30,
      lecturas: rawLecturas
          .map((item) => GpsReadingModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      lecturasValidas: json['lecturas_validas'] as int? ?? 0,
      precisionMediaM: (json['precision_media_m'] as num?)?.toDouble() ?? 0.0,
      dispersionM: (json['dispersion_m'] as num?)?.toDouble() ?? 0.0,
      calidad: json['calidad'] as String? ?? 'sin_captura',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duracion_s': duracionS,
      'lecturas': lecturas.map((e) => e.toJson()).toList(),
      'lecturas_validas': lecturasValidas,
      'precision_media_m': precisionMediaM,
      'dispersion_m': dispersionM,
      'calidad': calidad,
    };
  }

  CaptureModel copyWith({
    int? duracionS,
    List<GpsReadingModel>? lecturas,
    int? lecturasValidas,
    double? precisionMediaM,
    double? dispersionM,
    String? calidad,
  }) {
    return CaptureModel(
      duracionS: duracionS ?? this.duracionS,
      lecturas: lecturas ?? this.lecturas,
      lecturasValidas: lecturasValidas ?? this.lecturasValidas,
      precisionMediaM: precisionMediaM ?? this.precisionMediaM,
      dispersionM: dispersionM ?? this.dispersionM,
      calidad: calidad ?? this.calidad,
    );
  }
}
