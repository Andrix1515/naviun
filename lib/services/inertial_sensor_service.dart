import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/inertial_constants.dart';
import 'inertial_processor.dart';

/// Streams real device IMU samples and exposes an explicitly experimental estimate.
class InertialSensorService extends ChangeNotifier {
  InertialMotionProcessor _processor = InertialMotionProcessor();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  Timer? _availabilityTimer;
  DateTime? _lastNotification;

  bool _isActive = false;
  bool _isAvailable = false;
  bool _isCalibrating = false;
  bool _isCalibrated = false;
  String? _sensorError;
  double _stepLengthMeters = InertialConstants.defaultStepLengthMeters;

  bool get isActive => _isActive;
  bool get isAvailable => _isAvailable && _isActive;
  bool get isCalibrating => _isCalibrating;
  bool get isCalibrated => _isCalibrated;
  String? get sensorError => _sensorError;
  int get steps => _processor.steps;
  int get turnEvents => _processor.turnEvents;
  double get lastTurnDegrees => _processor.lastTurnDegrees;

  double get estimatedDistanceMeters => _snapshot.estimatedDistanceMeters;
  double get distanceUncertaintyMeters => _snapshot.distanceUncertaintyMeters;

  InertialMotionSnapshot get _snapshot => _processor.snapshot(
    stepLengthMeters: _stepLengthMeters,
    calibrated: _isCalibrated,
  );

  Future<void> startTracking({
    required double stepLengthMeters,
    required bool calibrated,
    bool reset = true,
  }) async {
    if (_isActive) {
      return;
    }
    _stepLengthMeters = stepLengthMeters;
    _isCalibrated = calibrated;
    _sensorError = null;
    _isAvailable = false;
    if (reset) {
      _processor = InertialMotionProcessor();
    }
    _isActive = true;
    _notifyListeners();

    _availabilityTimer?.cancel();
    _availabilityTimer = Timer(const Duration(seconds: 4), () {
      if (_isActive && !_isAvailable && _sensorError == null) {
        _sensorError =
            'No se recibieron datos de los sensores del dispositivo.';
        _notifyListeners(force: true);
      }
    });

    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_onAccelerometer, onError: _onSensorError, cancelOnError: false);
      _gyroscopeSubscription = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(_onGyroscope, onError: _onSensorError, cancelOnError: false);
    } catch (error) {
      _onSensorError(error);
    }
  }

  Future<void> beginStepCalibration() async {
    _isCalibrating = true;
    await startTracking(
      stepLengthMeters: InertialConstants.defaultStepLengthMeters,
      calibrated: false,
      reset: true,
    );
    _notifyListeners();
  }

  double? finishStepCalibration(double knownDistanceMeters) {
    _isCalibrating = false;
    if (_processor.steps == 0 || knownDistanceMeters <= 0) {
      _notifyListeners();
      return null;
    }
    final calibratedLength = knownDistanceMeters / _processor.steps;
    _stepLengthMeters = calibratedLength;
    _isCalibrated = true;
    _notifyListeners();
    return calibratedLength;
  }

  void cancelStepCalibration() {
    _isCalibrating = false;
    unawaited(stopTracking());
  }

  void _onAccelerometer(AccelerometerEvent event) {
    _isAvailable = true;
    _availabilityTimer?.cancel();
    _processor.addAccelerometer(
      x: event.x,
      y: event.y,
      z: event.z,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    _notifyListeners();
  }

  void _onGyroscope(GyroscopeEvent event) {
    _processor.addGyroscope(
      xRadiansPerSecond: event.x,
      yRadiansPerSecond: event.y,
      zRadiansPerSecond: event.z,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    _notifyListeners();
  }

  void _onSensorError(Object error) {
    _sensorError = 'No se pudo acceder a los sensores del dispositivo: $error';
    _isAvailable = false;
    _notifyListeners(force: true);
  }

  void _notifyListeners({bool force = false}) {
    final now = DateTime.now();
    if (force ||
        _lastNotification == null ||
        now.difference(_lastNotification!) >=
            const Duration(milliseconds: 250)) {
      _lastNotification = now;
      notifyListeners();
    }
  }

  Future<void> stopTracking() async {
    _availabilityTimer?.cancel();
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _isActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _availabilityTimer?.cancel();
    unawaited(_accelerometerSubscription?.cancel());
    unawaited(_gyroscopeSubscription?.cancel());
    super.dispose();
  }
}
