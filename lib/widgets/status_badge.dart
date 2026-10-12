import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/strings.dart';

/// Insignia accesible con icono y texto para representar estados.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  /// Insignia para estado de ruta
  factory StatusBadge.routeStatus(String status, {bool isDark = false}) {
    switch (status) {
      case RouteStatus.verified:
        return StatusBadge(
          label: AppStrings.statusVerified,
          icon: Icons.check_circle_outline,
          backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
          textColor: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF166534),
          borderColor: isDark ? const Color(0xFF059669) : const Color(0xFF22C55E),
        );
      case RouteStatus.pendingValidation:
        return StatusBadge(
          label: AppStrings.statusPendingValidation,
          icon: Icons.hourglass_top,
          backgroundColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
          textColor: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
          borderColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
        );
      case RouteStatus.outdated:
        return StatusBadge(
          label: AppStrings.statusOutdated,
          icon: Icons.warning_amber_rounded,
          backgroundColor: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
          textColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
          borderColor: isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
        );
      case RouteStatus.draft:
      default:
        return StatusBadge(
          label: AppStrings.statusDraft,
          icon: Icons.edit_note,
          backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          textColor: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
          borderColor: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
        );
    }
  }

  /// Insignia para datos de prueba obligatoria
  factory StatusBadge.testData({bool isDark = false}) {
    return StatusBadge(
      label: AppStrings.testDataBadge,
      icon: Icons.science_outlined,
      backgroundColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
      textColor: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
      borderColor: isDark ? const Color(0xFFD97706) : const Color(0xFFD97706),
    );
  }

  /// Insignia para calidad de GPS
  factory StatusBadge.gpsQuality(String quality, {bool isDark = false}) {
    switch (quality) {
      case GpsQuality.good:
        return StatusBadge(
          label: '${AppStrings.captureQuality} ${AppStrings.qualityGood}',
          icon: Icons.signal_cellular_alt,
          backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
          textColor: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF166534),
          borderColor: isDark ? const Color(0xFF059669) : const Color(0xFF22C55E),
        );
      case GpsQuality.regular:
        return StatusBadge(
          label: '${AppStrings.captureQuality} ${AppStrings.qualityRegular}',
          icon: Icons.signal_cellular_alt_2_bar,
          backgroundColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
          textColor: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
          borderColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
        );
      case GpsQuality.insufficient:
        return StatusBadge(
          label: '${AppStrings.captureQuality} ${AppStrings.qualityInsufficient}',
          icon: Icons.signal_cellular_alt_1_bar,
          backgroundColor: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
          textColor: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
          borderColor: isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
        );
      case GpsQuality.noCapture:
      default:
        return StatusBadge(
          label: AppStrings.qualityNoCapture,
          icon: Icons.location_off,
          backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          textColor: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
          borderColor: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
