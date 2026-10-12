import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../core/utils/date_utils.dart';
import 'waypoint_model.dart';

/// Modelo principal de una Ruta en Naviun.
class RouteModel {
  final String id;
  final String nombre;
  final String origen;
  final String destino;
  final String estado; // borrador | pendiente_validacion | verificada | desactualizada
  final bool esDatoDePrueba;
  final String creadaEn; // ISO8601
  final String? ultimaRevision; // ISO8601 | null
  final List<WaypointModel> puntos;

  RouteModel({
    String? id,
    required this.nombre,
    required this.origen,
    required this.destino,
    this.estado = RouteStatus.draft,
    this.esDatoDePrueba = false,
    String? creadaEn,
    this.ultimaRevision,
    List<WaypointModel>? puntos,
  })  : id = id ?? const Uuid().v4(),
        creadaEn = creadaEn ?? DateTime.now().toIso8601String(),
        puntos = puntos ?? [];

  /// Retorna el estado computado teniendo en cuenta si la ruta ha expirado (> 30 días sin revisión).
  String get estadoActual {
    if (estado == RouteStatus.draft) return RouteStatus.draft;

    final revDate = AppDateUtils.parseIso(ultimaRevision);
    if (revDate != null && AppDateUtils.isOutdated(revDate)) {
      return RouteStatus.outdated;
    }
    return estado;
  }

  bool get estaDesactualizada => estadoActual == RouteStatus.outdated;

  DateTime? get fechaUltimaRevision => AppDateUtils.parseIso(ultimaRevision);
  DateTime? get fechaCreacion => AppDateUtils.parseIso(creadaEn);

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final rawPuntos = json['puntos'] as List<dynamic>? ?? [];
    return RouteModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      nombre: json['nombre'] as String? ?? '',
      origen: json['origen'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      estado: json['estado'] as String? ?? RouteStatus.draft,
      esDatoDePrueba: json['es_dato_de_prueba'] as bool? ?? false,
      creadaEn: json['creada_en'] as String? ?? DateTime.now().toIso8601String(),
      ultimaRevision: json['ultima_revision'] as String?,
      puntos: rawPuntos
          .map((item) => WaypointModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'origen': origen,
      'destino': destino,
      'estado': estadoActual,
      'es_dato_de_prueba': esDatoDePrueba,
      'creada_en': creadaEn,
      'ultima_revision': ultimaRevision,
      'puntos': puntos.map((e) => e.toJson()).toList(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? nombre,
    String? origen,
    String? destino,
    String? estado,
    bool? esDatoDePrueba,
    String? creadaEn,
    String? ultimaRevision,
    List<WaypointModel>? puntos,
  }) {
    return RouteModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      estado: estado ?? this.estado,
      esDatoDePrueba: esDatoDePrueba ?? this.esDatoDePrueba,
      creadaEn: creadaEn ?? this.creadaEn,
      ultimaRevision: ultimaRevision ?? this.ultimaRevision,
      puntos: puntos ?? this.puntos,
    );
  }
}
