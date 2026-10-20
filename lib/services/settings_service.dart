import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../core/inertial_constants.dart';

/// Servicio de configuración y preferencias del usuario usando [SharedPreferences].
class SettingsService extends ChangeNotifier {
  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyTextScale = 'settings_text_scale';
  static const _keyTtsRate = 'settings_tts_rate';
  static const _keyTtsVolume = 'settings_tts_volume';
  static const _keyTtsEnabled = 'settings_tts_enabled';
  static const _keyVibrationEnabled = 'settings_vibration_enabled';
  static const _keyVoiceCommandEnabled = 'settings_voice_command_enabled';
  static const _keyAnnouncementMode = 'settings_announcement_mode';
  static const _keyHapticIntensity = 'settings_haptic_intensity';
  static const _keyInertialDemoEnabled = 'settings_inertial_demo_enabled';
  static const _keyCalibratedStepLength = 'settings_calibrated_step_length';
  static const _keyProximityRadius = 'settings_proximity_radius';
  static const _keyEmergencyContact = 'settings_emergency_contact';
  static const _keyHasSeenOnboarding = 'settings_has_seen_onboarding';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  ThemeMode get themeMode {
    final modeStr = _prefs.getString(_keyThemeMode);
    if (modeStr == 'light') return ThemeMode.light;
    if (modeStr == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await _prefs.setString(_keyThemeMode, value);
    notifyListeners();
  }

  double get textScaleMultiplier {
    return _prefs.getDouble(_keyTextScale) ?? 1.0;
  }

  Future<void> setTextScaleMultiplier(double multiplier) async {
    await _prefs.setDouble(_keyTextScale, multiplier);
    notifyListeners();
  }

  double get ttsRate {
    return _prefs.getDouble(_keyTtsRate) ?? 0.5;
  }

  Future<void> setTtsRate(double rate) async {
    await _prefs.setDouble(_keyTtsRate, rate);
    notifyListeners();
  }

  double get ttsVolume {
    return _prefs.getDouble(_keyTtsVolume) ?? 1.0;
  }

  Future<void> setTtsVolume(double volume) async {
    await _prefs.setDouble(_keyTtsVolume, volume);
    notifyListeners();
  }

  bool get ttsVoiceEnabled {
    return _prefs.getBool(_keyTtsEnabled) ?? true;
  }

  Future<void> setTtsVoiceEnabled(bool enabled) async {
    await _prefs.setBool(_keyTtsEnabled, enabled);
    notifyListeners();
  }

  bool get vibrationEnabled {
    return _prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_keyVibrationEnabled, enabled);
    notifyListeners();
  }

  bool get voiceCommandEnabled {
    return _prefs.getBool(_keyVoiceCommandEnabled) ?? false;
  }

  Future<void> setVoiceCommandEnabled(bool enabled) async {
    await _prefs.setBool(_keyVoiceCommandEnabled, enabled);
    notifyListeners();
  }

  String get announcementMode {
    final value = _prefs.getString(_keyAnnouncementMode);
    return value == 'screenreader' ? 'screenreader' : 'naviun';
  }

  Future<void> setAnnouncementMode(String mode) async {
    final normalized = mode == 'screenreader' ? 'screenreader' : 'naviun';
    await _prefs.setString(_keyAnnouncementMode, normalized);
    notifyListeners();
  }

  String get hapticIntensity {
    return _prefs.getString(_keyHapticIntensity) ?? 'media';
  }

  Future<void> setHapticIntensity(String intensity) async {
    final normalized = ['baja', 'media', 'alta'].contains(intensity) ? intensity : 'media';
    await _prefs.setString(_keyHapticIntensity, normalized);
    notifyListeners();
  }

  bool get inertialDemoEnabled {
    return _prefs.getBool(_keyInertialDemoEnabled) ??
        InertialConstants.imuEnabledByDefault;
  }

  Future<void> setInertialDemoEnabled(bool enabled) async {
    await _prefs.setBool(_keyInertialDemoEnabled, enabled);
    notifyListeners();
  }

  double? get calibratedStepLengthMeters {
    return _prefs.getDouble(_keyCalibratedStepLength);
  }

  Future<void> setCalibratedStepLengthMeters(double stepLengthMeters) async {
    if (!stepLengthMeters.isFinite || stepLengthMeters < 0.2 || stepLengthMeters > 1.5) {
      throw ArgumentError.value(stepLengthMeters, 'stepLengthMeters', 'Expected 0.2–1.5 m');
    }
    await _prefs.setDouble(_keyCalibratedStepLength, stepLengthMeters);
    notifyListeners();
  }

  double get proximityRadius {
    return _prefs.getDouble(_keyProximityRadius) ?? AppConstants.defaultProximityRadiusMeters;
  }

  Future<void> setProximityRadius(double radius) async {
    await _prefs.setDouble(_keyProximityRadius, radius);
    notifyListeners();
  }

  String get emergencyContact {
    return _prefs.getString(_keyEmergencyContact) ?? '';
  }

  Future<void> setEmergencyContact(String contact) async {
    await _prefs.setString(_keyEmergencyContact, contact.trim());
    notifyListeners();
  }

  bool get hasSeenOnboarding {
    return _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    await _prefs.setBool(_keyHasSeenOnboarding, seen);
    notifyListeners();
  }
}
