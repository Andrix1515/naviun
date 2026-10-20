import 'dart:math' as math;

import '../core/inertial_constants.dart';

class InertialMotionSnapshot {
  const InertialMotionSnapshot({
    required this.steps,
    required this.estimatedDistanceMeters,
    required this.distanceUncertaintyMeters,
    required this.turnEvents,
    required this.lastTurnDegrees,
  });

  final int steps;
  final double estimatedDistanceMeters;
  final double distanceUncertaintyMeters;
  final int turnEvents;
  final double lastTurnDegrees;
}

/// Pure-Dart experimental step and relative-rotation estimator.
class InertialMotionProcessor {
  bool _hasGravity = false;
  double _gravityX = 0;
  double _gravityY = 0;
  double _gravityZ = 0;
  double _lastAccelerationMagnitude = 9.81;
  double _lastVerticalAcceleration = 0;
  double _peakVerticalAcceleration = 0;
  bool _aboveStepThreshold = false;
  int? _lastStepTimestampMs;
  int? _lastGyroscopeTimestampMs;
  double _gyroBiasDegreesPerSecond = 0;
  double _relativeHeadingDegrees = 0;
  double _cumulativeRotationDegrees = 0;
  int _steps = 0;
  int _turnEvents = 0;
  double _lastTurnDegrees = 0;

  int get steps => _steps;
  int get turnEvents => _turnEvents;
  double get lastTurnDegrees => _lastTurnDegrees;
  double get cumulativeRotationDegrees => _cumulativeRotationDegrees;

  void addAccelerometer({
    required double x,
    required double y,
    required double z,
    required int timestampMs,
  }) {
    if (!_hasGravity) {
      _gravityX = x;
      _gravityY = y;
      _gravityZ = z;
      _hasGravity = true;
      _lastAccelerationMagnitude = _magnitude(x, y, z);
      return;
    }

    const gravitySmoothing = 0.8;
    _gravityX = gravitySmoothing * _gravityX + (1 - gravitySmoothing) * x;
    _gravityY = gravitySmoothing * _gravityY + (1 - gravitySmoothing) * y;
    _gravityZ = gravitySmoothing * _gravityZ + (1 - gravitySmoothing) * z;

    final gravityMagnitude = _magnitude(_gravityX, _gravityY, _gravityZ);
    if (gravityMagnitude <= 0.1) {
      return;
    }
    final verticalAcceleration =
        ((x - _gravityX) * _gravityX +
            (y - _gravityY) * _gravityY +
            (z - _gravityZ) * _gravityZ) /
        gravityMagnitude;
    _lastVerticalAcceleration = verticalAcceleration;
    _lastAccelerationMagnitude = _magnitude(x, y, z);

    const threshold = 0.8;
    if (verticalAcceleration >= threshold) {
      _aboveStepThreshold = true;
      _peakVerticalAcceleration =
          math.max(_peakVerticalAcceleration, verticalAcceleration);
      return;
    }

    if (_aboveStepThreshold && verticalAcceleration < threshold * 0.35) {
      final lastStep = _lastStepTimestampMs;
      final interval = lastStep == null ? null : timestampMs - lastStep;
      final refractoryMs = InertialConstants.minStepIntervalMs.round();
      if (_peakVerticalAcceleration >= threshold &&
          (interval == null || interval >= refractoryMs)) {
        _steps++;
        _lastStepTimestampMs = timestampMs;
      }
      _peakVerticalAcceleration = 0;
      _aboveStepThreshold = false;
    }
  }

  void addGyroscope({
    required double xRadiansPerSecond,
    required double yRadiansPerSecond,
    required double zRadiansPerSecond,
    required int timestampMs,
  }) {
    final lastTimestamp = _lastGyroscopeTimestampMs;
    _lastGyroscopeTimestampMs = timestampMs;
    if (lastTimestamp == null) {
      return;
    }

    final elapsedMs = timestampMs - lastTimestamp;
    if (elapsedMs <= 0 || elapsedMs > 250) {
      return;
    }

    final gravityMagnitude = _magnitude(_gravityX, _gravityY, _gravityZ);
    final gravityX = gravityMagnitude > 0.1 ? _gravityX / gravityMagnitude : 0.0;
    final gravityY = gravityMagnitude > 0.1 ? _gravityY / gravityMagnitude : 0.0;
    final gravityZ = gravityMagnitude > 0.1 ? _gravityZ / gravityMagnitude : 1.0;
    final projectedRateRadians =
        xRadiansPerSecond * gravityX +
        yRadiansPerSecond * gravityY +
        zRadiansPerSecond * gravityZ;
    final projectedRateDegrees = projectedRateRadians * 180 / math.pi;
    final gyroscopeMagnitude = _magnitude(
      xRadiansPerSecond,
      yRadiansPerSecond,
      zRadiansPerSecond,
    );

    final isStationary =
        (_lastAccelerationMagnitude - 9.81).abs() < 0.25 &&
        gyroscopeMagnitude < 0.12 &&
        _lastVerticalAcceleration.abs() < 0.2;
    if (isStationary) {
      _gyroBiasDegreesPerSecond =
          0.98 * _gyroBiasDegreesPerSecond + 0.02 * projectedRateDegrees;
    }

    final correctedRate = projectedRateDegrees - _gyroBiasDegreesPerSecond;
    if (correctedRate.abs() < 0.5) {
      return;
    }
    final rotation = correctedRate * elapsedMs / 1000;
    _relativeHeadingDegrees += rotation;
    _cumulativeRotationDegrees += rotation;

    final threshold = InertialConstants.turnThresholdDegrees;
    if (_relativeHeadingDegrees.abs() >= threshold) {
      final sign = _relativeHeadingDegrees.sign;
      _lastTurnDegrees = sign * threshold;
      _turnEvents++;
      _relativeHeadingDegrees -= sign * threshold;
    }
  }

  InertialMotionSnapshot snapshot({
    required double stepLengthMeters,
    required bool calibrated,
  }) {
    final distance = _steps * stepLengthMeters;
    final perStepUncertainty = calibrated
        ? 0.12
        : InertialConstants.defaultStepLengthUncertaintyMeters;
    return InertialMotionSnapshot(
      steps: _steps,
      estimatedDistanceMeters: distance,
      distanceUncertaintyMeters: math.sqrt(_steps) * perStepUncertainty,
      turnEvents: _turnEvents,
      lastTurnDegrees: _lastTurnDegrees,
    );
  }

  static double _magnitude(double x, double y, double z) {
    return math.sqrt(x * x + y * y + z * z);
  }
}
