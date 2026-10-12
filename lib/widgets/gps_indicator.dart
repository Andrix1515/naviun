import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants.dart';
import '../core/utils/geo_utils.dart';
import '../services/location_service.dart';

/// Indicador visual y accesible del estado de conexión y precisión del GPS.
class GpsIndicator extends StatelessWidget {
  final LocationStatus status;
  final Position? position;
  final VoidCallback? onSettingsPressed;

  const GpsIndicator({
    super.key,
    required this.status,
    this.position,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String text;
    IconData icon;
    Color color;

    switch (status) {
      case LocationStatus.ready:
        if (position != null) {
          final acc = position!.accuracy;
          text = 'GPS activo (${GeoUtils.formatAccuracy(acc)})';
          if (acc <= AppConstants.maxReliableNavigationAccuracyMeters) {
            icon = Icons.gps_fixed;
            color = isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight;
          } else {
            icon = Icons.gps_not_fixed;
            color = AppConstants.statusWarning;
          }
        } else {
          text = 'Buscando satélites GPS...';
          icon = Icons.gps_not_fixed;
          color = AppConstants.statusWarning;
        }
        break;
      case LocationStatus.serviceDisabled:
        text = 'GPS desactivado en el dispositivo';
        icon = Icons.location_disabled;
        color = AppConstants.statusError;
        break;
      case LocationStatus.permissionDenied:
      case LocationStatus.permissionDeniedForever:
        text = 'Permiso de ubicación no concedido';
        icon = Icons.security_update_warning;
        color = AppConstants.statusError;
        break;
      case LocationStatus.unknown:
        text = 'Comprobando estado de ubicación...';
        icon = Icons.sync;
        color = isDark ? Colors.white70 : Colors.black87;
        break;
    }

    return Semantics(
      label: 'Estado del GPS: $text',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppConstants.textPrimaryLight,
                ),
              ),
            ),
            if (status == LocationStatus.serviceDisabled ||
                status == LocationStatus.permissionDenied ||
                status == LocationStatus.permissionDeniedForever)
              TextButton(
                onPressed: onSettingsPressed,
                child: const Text(
                  'Activar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
