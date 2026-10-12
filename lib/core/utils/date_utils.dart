import '../constants.dart';

/// Utilidades para formatear fechas en español y verificar la vigencia de rutas.
class AppDateUtils {
  AppDateUtils._();

  static const List<String> _spanishMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Formato legible en español: "11 de octubre de 2026"
  static String formatReadableDate(DateTime? dateTime) {
    if (dateTime == null) return 'Sin fecha registrada';
    final day = dateTime.day;
    final month = _spanishMonths[dateTime.month - 1];
    final year = dateTime.year;
    return '$day de $month de $year';
  }

  /// Formato legible con hora: "11 de octubre de 2026, 15:30"
  static String formatReadableDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Sin fecha registrada';
    final dateStr = formatReadableDate(dateTime);
    final hourStr = dateTime.hour.toString().padLeft(2, '0');
    final minStr = dateTime.minute.toString().padLeft(2, '0');
    return '$dateStr, $hourStr:$minStr';
  }

  /// Determina si una fecha tiene más de [AppConstants.routeOutdatedDays] días (30 días).
  static bool isOutdated(DateTime? lastReviewDate, {DateTime? now}) {
    if (lastReviewDate == null) return true;
    final current = now ?? DateTime.now();
    final difference = current.difference(lastReviewDate);
    return difference.inDays > AppConstants.routeOutdatedDays;
  }

  /// Convierte cadena ISO8601 a DateTime seguro.
  static DateTime? parseIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Convierte DateTime a cadena ISO8601.
  static String? toIso(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}
