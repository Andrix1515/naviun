/// Constantes experimentales para la estimación inercial (IMU).
/// Todas las tolerancias son provisionales y deben calibrarse en pruebas reales.
class InertialConstants {
  InertialConstants._();

  static const bool imuEnabledByDefault = false;
  static const double sampleRateHz = 50.0;
  static const double minStepIntervalMs = 300.0;
  static const double defaultStepLengthMeters = 0.72;
  static const double defaultStepLengthUncertaintyMeters = 0.25;
  static const double turnThresholdDegrees = 45.0;
  static const double gpsReprojectionVarianceMeters = 10.0;
  static const double progressSigmaThresholdMeters = 3.0;
  static const double arrivalMarginMeters = 1.5;
}
