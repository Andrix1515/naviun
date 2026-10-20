import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/services/haptic_service.dart';

void main() {
  group('HapticService', () {
    test('patrones tienen definiciones no vacías y distintas', () {
      final patterns = HapticPattern.values;

      expect(patterns, isNotEmpty);
      expect(patterns.length, 8);

      for (final pattern in patterns) {
        expect(pattern.waveform, isNotEmpty);
        expect(pattern.totalDurationMs, greaterThan(0));
      }

      final uniqueDurations = patterns.map((p) => p.totalDurationMs).toSet();
      expect(uniqueDurations.length, greaterThanOrEqualTo(patterns.length - 1));
    });

    test('cada patrón tiene un código legible', () {
      expect(HapticPattern.a.label, 'A');
      expect(HapticPattern.fromLabel('D'), HapticPattern.d);
      expect(HapticPattern.fromLabel('z'), isNull);
    });
  });
}
