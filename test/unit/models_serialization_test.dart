import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/core/constants.dart';
import 'package:naviun/data/models/capture_model.dart';
import 'package:naviun/data/models/route_model.dart';
import 'package:naviun/data/models/warning_model.dart';
import 'package:naviun/data/models/waypoint_model.dart';

void main() {
  group('Models Serialization / Deserialization', () {
    test('RouteModel serializa y deserializa correctamente manteniendo integridad', () {
      final route = RouteModel(
        id: 'test-uuid-1',
        nombre: 'Entrada a Biblioteca Central',
        origen: 'Puerta Principal UNCP',
        destino: 'Biblioteca Central',
        estado: RouteStatus.verified,
        esDatoDePrueba: true,
        creadaEn: '2026-10-10T12:00:00.000Z',
        ultimaRevision: '2026-10-10T12:30:00.000Z',
        puntos: [
          WaypointModel(
            id: 'wp-1',
            orden: 1,
            nombre: 'Entrada Principal',
            tipo: WaypointType.start,
            instruccion: 'Avanza 10 metros en línea recta.',
            latitud: -12.056388,
            longitud: -75.218888,
            posicionAjustadaManual: true,
            captura: CaptureModel(
              duracionS: 30,
              lecturas: [
                GpsReadingModel(
                  lat: -12.056388,
                  lon: -75.218888,
                  precisionM: 4.2,
                  timestamp: '2026-10-10T12:00:10.000Z',
                ),
              ],
              lecturasValidas: 1,
              precisionMediaM: 4.2,
              dispersionM: 1.1,
              calidad: GpsQuality.good,
            ),
            advertencias: [
              WarningModel(
                tipo: WarningType.stairs,
                nota: 'Grada pequeña de 5 centímetros de altura.',
                fechaObservacion: '2026-10-10T12:05:00.000Z',
                temporal: false,
                estadoRevision: 'revisada',
              ),
            ],
          ),
        ],
      );

      final jsonMap = route.toJson();
      final jsonString = jsonEncode(jsonMap);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final reconstructed = RouteModel.fromJson(decodedMap);

      expect(reconstructed.id, equals('test-uuid-1'));
      expect(reconstructed.nombre, equals('Entrada a Biblioteca Central'));
      expect(reconstructed.origen, equals('Puerta Principal UNCP'));
      expect(reconstructed.destino, equals('Biblioteca Central'));
      expect(reconstructed.esDatoDePrueba, isTrue);
      expect(reconstructed.puntos.length, equals(1));

      final wp = reconstructed.puntos.first;
      expect(wp.id, equals('wp-1'));
      expect(wp.tipo, equals(WaypointType.start));
      expect(wp.posicionAjustadaManual, isTrue);
      expect(wp.latitud, equals(-12.056388));
      expect(wp.longitud, equals(-75.218888));
      expect(wp.captura.calidad, equals(GpsQuality.good));
      expect(wp.captura.lecturas.length, equals(1));
      expect(wp.advertencias.length, equals(1));
      expect(wp.advertencias.first.tipo, equals(WarningType.stairs));
      expect(wp.advertencias.first.nota, equals('Grada pequeña de 5 centímetros de altura.'));
    });

    test('soporta coordenadas nulas para puntos sin GPS o rutas de prueba', () {
      final wp = WaypointModel(
        orden: 1,
        nombre: 'Punto Techo Cubierto',
        tipo: WaypointType.path,
        instruccion: 'Continúa por el pasadizo techado.',
        latitud: null,
        longitud: null,
      );

      final json = wp.toJson();
      expect(json['latitud'], isNull);
      expect(json['longitud'], isNull);

      final parsed = WaypointModel.fromJson(json);
      expect(parsed.latitud, isNull);
      expect(parsed.longitud, isNull);
      expect(parsed.hasCoordinates, isFalse);
    });
  });
}
