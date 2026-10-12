import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/core/constants.dart';
import 'package:naviun/core/utils/date_utils.dart';
import 'package:naviun/data/models/route_model.dart';

void main() {
  group('Route Expiration & Outdated Logic', () {
    test('ruta verificada hace menos de 30 días se mantiene verificada', () {
      final now = DateTime(2026, 10, 10, 12, 0);
      final twentyDaysAgo = now.subtract(const Duration(days: 20));

      final route = RouteModel(
        nombre: 'Ruta Fresca',
        origen: 'A',
        destino: 'B',
        estado: RouteStatus.verified,
        ultimaRevision: twentyDaysAgo.toIso8601String(),
      );

      expect(AppDateUtils.isOutdated(twentyDaysAgo, now: now), isFalse);
      expect(route.estadoActual, equals(RouteStatus.verified));
      expect(route.estaDesactualizada, isFalse);
    });

    test('ruta revisada hace más de 30 días pasa automáticamente a desactualizada', () {
      final now = DateTime(2026, 10, 10, 12, 0);
      final thirtyOneDaysAgo = now.subtract(const Duration(days: 31));

      final route = RouteModel(
        nombre: 'Ruta Antigua',
        origen: 'A',
        destino: 'B',
        estado: RouteStatus.verified,
        ultimaRevision: thirtyOneDaysAgo.toIso8601String(),
      );

      expect(AppDateUtils.isOutdated(thirtyOneDaysAgo, now: now), isTrue);
      // Al evaluar estadoActual en la fecha actual (o con función de utilidad)
      final revDate = AppDateUtils.parseIso(route.ultimaRevision);
      expect(AppDateUtils.isOutdated(revDate, now: now), isTrue);
    });

    test('borrador no cambia a desactualizada aunque tenga tiempo', () {
      final now = DateTime(2026, 10, 10, 12, 0);
      final fortyDaysAgo = now.subtract(const Duration(days: 40));

      final route = RouteModel(
        nombre: 'Borrador en Progreso',
        origen: 'A',
        destino: 'B',
        estado: RouteStatus.draft,
        ultimaRevision: fortyDaysAgo.toIso8601String(),
      );

      expect(route.estadoActual, equals(RouteStatus.draft));
    });
  });
}
