import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/core/constants.dart';
import 'package:naviun/data/models/warning_model.dart';
import 'package:naviun/data/models/waypoint_model.dart';
import 'package:naviun/widgets/accessible_button.dart';
import 'package:naviun/widgets/instruction_panel.dart';
import 'package:naviun/widgets/status_badge.dart';
import 'package:naviun/widgets/warning_card.dart';

void main() {
  group('Accessible Widgets & Semantics Tests', () {
    testWidgets('AccessibleButton contiene Semantics con label y cumple objetivo táctil mínimo', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: 'Iniciar ruta Pabellón A',
              semanticHint: 'Inicia el guiado accesible',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Verificar que el widget Semantics existe con la etiqueta exacta
      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Iniciar ruta Pabellón A',
      );
      expect(semanticsFinder, findsOneWidget);

      // Verificar tamaño táctil (mínimo 48 dp de alto)
      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(48.0));

      // Verificar pulsación
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('StatusBadge contiene Semantics con estado de ruta', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge.routeStatus(RouteStatus.verified),
          ),
        ),
      );

      final badgeSemantics = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Estado: Verificada',
      );
      expect(badgeSemantics, findsOneWidget);
    });

    testWidgets('StatusBadge de datos de prueba tiene Semantics correcto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge.testData(),
          ),
        ),
      );

      final badgeSemantics = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Estado: DATOS DE PRUEBA',
      );
      expect(badgeSemantics, findsOneWidget);
    });

    testWidgets('WarningCard anuncia el tipo, nota y fecha de observación', (tester) async {
      final warning = WarningModel(
        tipo: WarningType.stairs,
        nota: 'Primer escalón con desnivel.',
        fechaObservacion: '2026-10-10T12:00:00Z',
        temporal: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WarningCard(warning: warning),
          ),
        ),
      );

      expect(find.text('Escalera'), findsOneWidget);
      expect(find.text('Primer escalón con desnivel.'), findsOneWidget);
      expect(find.text('TEMPORAL'), findsOneWidget);

      final warningSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Primer escalón con desnivel.') &&
            widget.properties.label!.contains('Escalera'),
      );
      expect(warningSemantics, findsOneWidget);
    });

    testWidgets('InstructionPanel renderiza instrucción, progreso e icono accesible', (tester) async {
      final waypoint = WaypointModel(
        orden: 2,
        nombre: 'Giro hacia el patio central',
        tipo: WaypointType.turn,
        instruccion: 'Gira 90 grados a tu derecha.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstructionPanel(
              currentWaypoint: waypoint,
              currentIndex: 1,
              totalWaypoints: 4,
            ),
          ),
        ),
      );

      expect(find.text('Punto 2 de 4'), findsOneWidget);
      expect(find.text('Giro hacia el patio central'), findsOneWidget);
      expect(find.text('Gira 90 grados a tu derecha.'), findsOneWidget);

      final panelSemantics = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Punto 2 de 4') &&
            widget.properties.label!.contains('Giro hacia el patio central'),
      );
      expect(panelSemantics, findsOneWidget);
    });
  });
}
