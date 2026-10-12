/// Modelo de Advertencia manual asociada a un punto de control.
class WarningModel {
  final String tipo; // escalera | rampa | bordillo | superficie_irregular | puerta | obstaculo_temporal | otro
  final String nota;
  final String fechaObservacion; // ISO8601
  final bool temporal;
  final String estadoRevision; // pendiente | revisada

  WarningModel({
    required this.tipo,
    required this.nota,
    required this.fechaObservacion,
    this.temporal = false,
    this.estadoRevision = 'pendiente',
  });

  factory WarningModel.fromJson(Map<String, dynamic> json) {
    return WarningModel(
      tipo: json['tipo'] as String? ?? 'otro',
      nota: json['nota'] as String? ?? '',
      fechaObservacion: json['fecha_observacion'] as String? ?? DateTime.now().toIso8601String(),
      temporal: json['temporal'] as bool? ?? false,
      estadoRevision: json['estado_revision'] as String? ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'nota': nota,
      'fecha_observacion': fechaObservacion,
      'temporal': temporal,
      'estado_revision': estadoRevision,
    };
  }

  WarningModel copyWith({
    String? tipo,
    String? nota,
    String? fechaObservacion,
    bool? temporal,
    String? estadoRevision,
  }) {
    return WarningModel(
      tipo: tipo ?? this.tipo,
      nota: nota ?? this.nota,
      fechaObservacion: fechaObservacion ?? this.fechaObservacion,
      temporal: temporal ?? this.temporal,
      estadoRevision: estadoRevision ?? this.estadoRevision,
    );
  }
}
