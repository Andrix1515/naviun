import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../core/utils/geo_utils.dart';
import '../data/models/waypoint_model.dart';

/// Panel central de alto contraste con la instrucción activa para el seguimiento de ruta.
class InstructionPanel extends StatelessWidget {
  final WaypointModel currentWaypoint;
  final int currentIndex;
  final int totalWaypoints;
  final double? distanceMeters;
  final double? currentGpsAccuracy;

  const InstructionPanel({
    super.key,
    required this.currentWaypoint,
    required this.currentIndex,
    required this.totalWaypoints,
    this.distanceMeters,
    this.currentGpsAccuracy,
  });

  IconData _getWaypointIcon(String tipo) {
    switch (tipo) {
      case WaypointType.start:
        return Icons.play_circle_fill;
      case WaypointType.turn:
        return Icons.turn_right;
      case WaypointType.door:
        return Icons.meeting_room;
      case WaypointType.stairs:
        return Icons.stairs;
      case WaypointType.destination:
        return Icons.flag;
      case WaypointType.path:
      default:
        return Icons.navigation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _getWaypointIcon(currentWaypoint.tipo);

    // Solo se muestra distancia aproximada si la precisión es suficiente (< 20m) y hay distancia
    final showDistance = distanceMeters != null &&
        currentGpsAccuracy != null &&
        currentGpsAccuracy! <= AppConstants.maxReliableNavigationAccuracyMeters;

    final progressText = AppStrings.navPointProgress
        .replaceAll('{current}', '${currentIndex + 1}')
        .replaceAll('{total}', '$totalWaypoints');

    return Semantics(
      container: true,
      label:
          '$progressText. Siguiente punto: ${currentWaypoint.nombre}. '
          'Instrucción: ${currentWaypoint.instruccion}. '
          '${showDistance ? "Distancia aproximada: ${GeoUtils.formatDistance(distanceMeters)}." : ""}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
            width: 2.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progreso de puntos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
                    ),
                  ),
                ),
                if (currentWaypoint.advertencias.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.accentGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          '${currentWaypoint.advertencias.length} advertencia(s)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Nombre del punto y tipo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentWaypoint.nombre,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppConstants.textPrimaryLight,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Instrucción en texto grande y claro
            Text(
              currentWaypoint.instruccion,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppConstants.textPrimaryLight,
                height: 1.35,
              ),
            ),

            if (showDistance) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 20, color: AppConstants.accentGold),
                  const SizedBox(width: 6),
                  Text(
                    '${AppStrings.navApproxDistance} ${GeoUtils.formatDistance(distanceMeters)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : AppConstants.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
