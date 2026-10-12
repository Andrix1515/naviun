import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/capture_model.dart';
import 'stabilization.dart';

/// Estado de los permisos y disponibilidad del GPS.
enum LocationStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  ready,
  unknown,
}

/// Servicio de gestión de GPS y captura estabilizada de puntos.
class LocationService extends ChangeNotifier {
  final GpsStabilizationAlgorithm _stabilizationAlgorithm;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _currentPosition;
  LocationStatus _status = LocationStatus.unknown;

  LocationService({GpsStabilizationAlgorithm? stabilizationAlgorithm})
      : _stabilizationAlgorithm = stabilizationAlgorithm ?? const GpsStabilizationAlgorithm();

  Position? get currentPosition => _currentPosition;
  LocationStatus get status => _status;
  bool get isGpsReady => _status == LocationStatus.ready;

  /// Verifica el estado de disponibilidad y permisos del GPS.
  Future<LocationStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = LocationStatus.serviceDisabled;
      notifyListeners();
      return _status;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _status = LocationStatus.permissionDenied;
      notifyListeners();
      return _status;
    }

    if (permission == LocationPermission.deniedForever) {
      _status = LocationStatus.permissionDeniedForever;
      notifyListeners();
      return _status;
    }

    _status = LocationStatus.ready;
    notifyListeners();
    return _status;
  }

  /// Solicita permisos de ubicación al usuario.
  Future<LocationStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = LocationStatus.serviceDisabled;
      notifyListeners();
      return _status;
    }

    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _status = LocationStatus.permissionDenied;
    } else if (permission == LocationPermission.deniedForever) {
      _status = LocationStatus.permissionDeniedForever;
    } else {
      _status = LocationStatus.ready;
      _startTrackingCurrentPosition();
    }

    notifyListeners();
    return _status;
  }

  /// Abre los ajustes del sistema para habilitar ubicación o permisos.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Inicia el rastreo en tiempo real para el mapa y monitoreo continuo.
  void _startTrackingCurrentPosition() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen(
      (pos) {
        _currentPosition = pos;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Error en position stream: $err');
      },
    );
  }

  /// Obtiene la posición actual de forma asíncrona si está disponible.
  Future<Position?> getCurrentPositionSafe() async {
    final s = await checkStatus();
    if (s != LocationStatus.ready) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _currentPosition = pos;
      notifyListeners();
      return pos;
    } catch (_) {
      return _currentPosition;
    }
  }

  /// Inicia una sesión de estabilización GPS durante [durationSeconds].
  ///
  /// Emite lecturas mediante [onProgress] con:
  /// - segundos transcurridos
  /// - segundos restantes
  /// - total lecturas capturadas hasta el momento
  /// - última precisión reportada
  Stream<StabilizationProgress> startStabilizationCapture({
    required int durationSeconds,
  }) {
    late StreamController<StabilizationProgress> controller;
    StreamSubscription<Position>? captureSub;
    Timer? countdownTimer;
    final readings = <GpsReadingModel>[];
    int elapsedSeconds = 0;

    void cleanup() {
      countdownTimer?.cancel();
      captureSub?.cancel();
    }

    controller = StreamController<StabilizationProgress>(
      onListen: () async {
        final currentStatus = await checkStatus();
        if (currentStatus != LocationStatus.ready) {
          controller.addError('El GPS no está listo o los permisos fueron denegados.');
          await controller.close();
          return;
        }

        // Suscribirse al flujo de alta precisión
        captureSub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        ).listen((pos) {
          final reading = GpsReadingModel(
            lat: pos.latitude,
            lon: pos.longitude,
            precisionM: pos.accuracy,
            timestamp: DateTime.now().toIso8601String(),
          );
          readings.add(reading);

          controller.add(
            StabilizationProgress(
              elapsedSeconds: elapsedSeconds,
              remainingSeconds: durationSeconds - elapsedSeconds,
              totalDurationSeconds: durationSeconds,
              capturedReadingsCount: readings.length,
              latestAccuracyMeters: pos.accuracy,
              isCompleted: false,
            ),
          );
        });

        // Temporizador de conteo por segundos
        countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          elapsedSeconds++;
          final remaining = durationSeconds - elapsedSeconds;

          if (remaining <= 0) {
            timer.cancel();
            captureSub?.cancel();

            // Procesar con el algoritmo puro de estabilización
            final result = _stabilizationAlgorithm.process(readings);

            controller.add(
              StabilizationProgress(
                elapsedSeconds: durationSeconds,
                remainingSeconds: 0,
                totalDurationSeconds: durationSeconds,
                capturedReadingsCount: readings.length,
                latestAccuracyMeters: readings.isNotEmpty ? readings.last.precisionM : 0.0,
                isCompleted: true,
                result: result,
              ),
            );
            controller.close();
          } else {
            controller.add(
              StabilizationProgress(
                elapsedSeconds: elapsedSeconds,
                remainingSeconds: remaining,
                totalDurationSeconds: durationSeconds,
                capturedReadingsCount: readings.length,
                latestAccuracyMeters: readings.isNotEmpty ? readings.last.precisionM : 0.0,
                isCompleted: false,
              ),
            );
          }
        });
      },
      onCancel: () {
        cleanup();
      },
    );

    return controller.stream;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

/// Progreso emitido durante la captura de estabilización GPS.
class StabilizationProgress {
  final int elapsedSeconds;
  final int remainingSeconds;
  final int totalDurationSeconds;
  final int capturedReadingsCount;
  final double latestAccuracyMeters;
  final bool isCompleted;
  final StabilizationResult? result;

  const StabilizationProgress({
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.totalDurationSeconds,
    required this.capturedReadingsCount,
    required this.latestAccuracyMeters,
    required this.isCompleted,
    this.result,
  });

  double get progressFraction {
    if (totalDurationSeconds <= 0) return 1.0;
    return (elapsedSeconds / totalDurationSeconds).clamp(0.0, 1.0);
  }
}
