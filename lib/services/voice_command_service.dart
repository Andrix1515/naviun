import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Servicio para escuchar comandos por voz en español con un patrón de uso seguro.
class VoiceCommandService {
  VoiceCommandService();

  final SpeechToText _speech = SpeechToText();

  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) {
          if (status == 'notListening') {
            _isListening = false;
          }
        },
      );
      return _isAvailable;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  Future<bool> startListening({
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 3),
    required void Function(String text) onResult,
    void Function(String message)? onError,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('El reconocimiento de voz no está disponible en este dispositivo.');
        return false;
      }
    }

    try {
      _isListening = true;
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          localeId: 'es_PE',
        ),
        onResult: (result) {
          final text = result.recognizedWords.trim();
          if (text.isNotEmpty) {
            _lastWords = text;
            onResult(text);
          }
        },
      );
      return true;
    } catch (_) {
      _isListening = false;
      onError?.call('No pude escuchar el comando. Repite la acción o prueba otra vez.');
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
    }
    _isListening = false;
  }
}
