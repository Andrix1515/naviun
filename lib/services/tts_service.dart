import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/strings.dart';

/// Servicio de Texto a Voz (TTS) adaptado para español de Perú (es-PE) con respaldos.
class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;
  String _selectedLanguage = 'es-PE';

  bool get isPlaying => _isPlaying;
  String get selectedLanguage => _selectedLanguage;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await _flutterTts.awaitSpeakCompletion(true);

        // Intentar configurar idioma es-PE o fallbacks
        final languages = await _flutterTts.getLanguages;
        final List<String> available = (languages as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        if (available.contains('es-PE')) {
          _selectedLanguage = 'es-PE';
        } else if (available.contains('es-ES')) {
          _selectedLanguage = 'es-ES';
        } else if (available.contains('es-MX')) {
          _selectedLanguage = 'es-MX';
        } else {
          // Buscar cualquier variante de español
          final esLang = available.firstWhere(
            (lang) => lang.toLowerCase().startsWith('es'),
            orElse: () => 'es-ES',
          );
          _selectedLanguage = esLang;
        }

        await _flutterTts.setLanguage(_selectedLanguage);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);

        _flutterTts.setStartHandler(() {
          _isPlaying = true;
          notifyListeners();
        });

        _flutterTts.setCompletionHandler(() {
          _isPlaying = false;
          notifyListeners();
        });

        _flutterTts.setErrorHandler((msg) {
          _isPlaying = false;
          notifyListeners();
        });
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error al inicializar TTS: $e');
    }
  }

  Future<void> speak(
    String text, {
    double rate = 0.5,
    double volume = 1.0,
    bool enabled = true,
  }) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      await init();
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(volume);
      _isPlaying = true;
      notifyListeners();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error en speak: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> testVoice({double rate = 0.5, double volume = 1.0}) async {
    await stop();
    await speak(
      AppStrings.testVoicePhrase,
      rate: rate,
      volume: volume,
      enabled: true,
    );
  }
}
