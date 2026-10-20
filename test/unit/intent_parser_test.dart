import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/services/intent_parser.dart';

void main() {
  group('IntentParser', () {
    test('normaliza y reconoce comandos de navegación básicos', () {
      final repeat = IntentParser.parse('repetir instrucción');
      expect(repeat.type, VoiceCommandType.repeat);

      final pause = IntentParser.parse('pausa');
      expect(pause.type, VoiceCommandType.pause);

      final resume = IntentParser.parse('reanudar');
      expect(resume.type, VoiceCommandType.resume);

      final arrival = IntentParser.parse('ya llegué');
      expect(arrival.type, VoiceCommandType.arrived);

      final status = IntentParser.parse('dónde estoy');
      expect(status.type, VoiceCommandType.status);
    });

    test('interpreta destino con match aproximado', () {
      final routeNames = ['Aula Magna', 'Laboratorio 2', 'Entrada principal'];
      final parsed = IntentParser.parse('ir a aula magna', routeNames: routeNames);

      expect(parsed.type, VoiceCommandType.destination);
      expect(parsed.destination, 'Aula Magna');
      expect(parsed.requiresConfirmation, isTrue);
    });

    test('normaliza textos con tildes y signos', () {
      final normalized = IntentParser.normalize('¡Quiero ir a la ruta de Aula Magna!');
      expect(normalized, 'quiero ir a la ruta de aula magna');
    });
  });
}
