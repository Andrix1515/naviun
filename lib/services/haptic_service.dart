import 'package:flutter/services.dart';

/// Patrón háptico reproducible y medible para la navegación de Naviun.
enum HapticPattern {
  a('A'),
  b('B'),
  c('C'),
  d('D'),
  e('E'),
  f('F'),
  g('G'),
  h('H');

  const HapticPattern(this.label);

  final String label;

  static HapticPattern? fromLabel(String value) {
    final normalized = value.trim().toUpperCase();
    for (final pattern in HapticPattern.values) {
      if (pattern.label == normalized) {
        return pattern;
      }
    }
    return null;
  }

  List<int> get waveform {
    switch (this) {
      case HapticPattern.a:
        return [80];
      case HapticPattern.b:
        return [80, 120];
      case HapticPattern.c:
        return [40, 180];
      case HapticPattern.d:
        return [140, 80];
      case HapticPattern.e:
        return [50, 50, 80, 50, 70];
      case HapticPattern.f:
        return [180, 140];
      case HapticPattern.g:
        return [30];
      case HapticPattern.h:
        return [60, 120, 180];
    }
  }

  int get totalDurationMs => waveform.fold<int>(0, (sum, value) => sum + value);

}

/// Servicio que abstrae vibración personalizada, soporte del motor y respaldo con HapticFeedback.
class HapticService {
  HapticService();

  static const MethodChannel _channel = MethodChannel('naviun/haptics');

  Future<Map<String, bool>> get capabilities async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getCapabilities');
      return {
        'hasVibrator': result?['hasVibrator'] == true,
        'supportsWaveform': result?['supportsWaveform'] == true,
        'supportsAmplitude': result?['supportsAmplitude'] == true,
      };
    } on PlatformException {
      return const {
        'hasVibrator': false,
        'supportsWaveform': false,
        'supportsAmplitude': false,
      };
    } on MissingPluginException {
      return const {
        'hasVibrator': false,
        'supportsWaveform': false,
        'supportsAmplitude': false,
      };
    }
  }

  Future<bool> get hasVibrator async => (await capabilities)['hasVibrator'] ?? false;

  Future<bool> get supportsCustomWaveform async =>
      (await capabilities)['supportsWaveform'] ?? false;

  Future<bool> get supportsAmplitudeControl async =>
      (await capabilities)['supportsAmplitude'] ?? false;

  Future<void> trigger(
    HapticPattern pattern, {
    bool enabled = true,
    String intensity = 'media',
  }) async {
    if (!enabled) {
      return;
    }

    try {
      final supportsWaveform = await supportsCustomWaveform;
      if (supportsWaveform) {
        await _channel.invokeMethod('vibratePattern', {
          'pattern': pattern.waveform,
          'intensity': intensity,
        });
        return;
      }
    } on PlatformException {
      // Fallback seguro: usar HapticFeedback cuando el motor no soporta patrones personalizados.
    } on MissingPluginException {
      // The app has no native waveform handler on this platform.
    }

    _fallback(pattern);
  }

  void _fallback(HapticPattern pattern) {
    switch (pattern) {
      case HapticPattern.a:
        HapticFeedback.lightImpact();
        break;
      case HapticPattern.b:
        HapticFeedback.mediumImpact();
        break;
      case HapticPattern.c:
        HapticFeedback.selectionClick();
        break;
      case HapticPattern.d:
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.e:
        HapticFeedback.heavyImpact();
        break;
      case HapticPattern.f:
        HapticFeedback.mediumImpact();
        break;
      case HapticPattern.g:
        HapticFeedback.selectionClick();
        break;
      case HapticPattern.h:
        HapticFeedback.mediumImpact();
        break;
    }
  }
}
