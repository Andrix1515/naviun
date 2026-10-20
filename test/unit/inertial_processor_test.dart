import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:naviun/services/inertial_processor.dart';

void main() {
  group('InertialMotionProcessor', () {
    test('detects steps from a labelled synthetic 1.8 Hz walking signal', () {
      final processor = InertialMotionProcessor();
      processor.addAccelerometer(x: 0, y: 0, z: 9.81, timestampMs: 0);

      const sampleRateHz = 50;
      const durationSeconds = 5;
      for (var sample = 1; sample <= sampleRateHz * durationSeconds; sample++) {
        final timeSeconds = sample / sampleRateHz;
        final verticalAcceleration =
            1.5 * math.sin(2 * math.pi * 1.8 * timeSeconds);
        processor.addAccelerometer(
          x: 0,
          y: 0,
          z: 9.81 + verticalAcceleration,
          timestampMs: sample * 20,
        );
      }

      expect(processor.steps, inInclusiveRange(7, 11));
      expect(
        processor
            .snapshot(stepLengthMeters: 0.7, calibrated: true)
            .estimatedDistanceMeters,
        greaterThan(0),
      );
    });

    test('integrates 30 degrees per second to approximately 90 degrees', () {
      final processor = InertialMotionProcessor();
      processor.addAccelerometer(x: 0, y: 0, z: 9.81, timestampMs: 0);
      processor.addGyroscope(
        xRadiansPerSecond: 0,
        yRadiansPerSecond: 0,
        zRadiansPerSecond: 30 * math.pi / 180,
        timestampMs: 0,
      );

      for (var sample = 1; sample <= 150; sample++) {
        processor.addGyroscope(
          xRadiansPerSecond: 0,
          yRadiansPerSecond: 0,
          zRadiansPerSecond: 30 * math.pi / 180,
          timestampMs: sample * 20,
        );
      }

      expect(processor.cumulativeRotationDegrees, closeTo(90, 0.5));
      expect(processor.turnEvents, 2);
    });
  });
}
