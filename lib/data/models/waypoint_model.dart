import 'package:uuid/uuid.dart';
import 'capture_model.dart';
import 'warning_model.dart';

/// Modelo de un Punto de Control (Waypoint) en una ruta.
class WaypointModel {
  final String id;
  final int orden;
  final String nombre;
  final String tipo; // inicio | camino | giro | puerta | escalera | destino
  final String instruccion;
  final double? latitud;
  final double? longitud;
  final bool posicionAjustadaManual;
  final CaptureModel captura;
  final List<WarningModel> advertencias;

  WaypointModel({
    String? id,
    required this.orden,
    required this.nombre,
    required this.tipo,
    required this.instruccion,
    this.latitud,
    this.longitud,
    this.posicionAjustadaManual = false,
    CaptureModel? captura,
    List<WarningModel>? advertencias,
  })  : id = id ?? const Uuid().v4(),
        captura = captura ?? CaptureModel.empty(),
        advertencias = advertencias ?? [];

  bool get hasCoordinates => latitud != null && longitud != null;

  factory WaypointModel.fromJson(Map<String, dynamic> json) {
    final rawWarnings = json['advertencias'] as List<dynamic>? ?? [];
    return WaypointModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      orden: json['orden'] as int? ?? 1,
      nombre: json['nombre'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'camino',
      instruccion: json['instruccion'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      posicionAjustadaManual: json['posicion_ajustada_manual'] as bool? ?? false,
      captura: json['captura'] != null
          ? CaptureModel.fromJson(json['captura'] as Map<String, dynamic>)
          : CaptureModel.empty(),
      advertencias: rawWarnings
          .map((item) => WarningModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orden': orden,
      'nombre': nombre,
      'tipo': tipo,
      'instruccion': instruccion,
      'latitud': latitud,
      'longitud': longitud,
      'posicion_ajustada_manual': posicionAjustadaManual,
      'captura': captura.toJson(),
      'advertencias': advertencias.map((e) => e.toJson()).toList(),
    };
  }

  WaypointModel copyWith({
    String? id,
    int? orden,
    String? nombre,
    String? tipo,
    String? instruccion,
    double? latitud,
    double? longitud,
    bool? posicionAjustadaManual,
    CaptureModel? captura,
    List<WarningModel>? advertencias,
  }) {
    return WaypointModel(
      id: id ?? this.id,
      orden: orden ?? this.orden,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      instruccion: instruccion ?? this.instruccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      posicionAjustadaManual: posicionAjustadaManual ?? this.posicionAjustadaManual,
      captura: captura ?? this.captura,
      advertencias: advertencias ?? this.advertencias,
    );
  }
}
