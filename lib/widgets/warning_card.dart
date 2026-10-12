import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../core/utils/date_utils.dart';
import '../data/models/warning_model.dart';

/// Tarjeta accesible para mostrar una advertencia manual con su fecha de observación.
class WarningCard extends StatelessWidget {
  final WarningModel warning;
  final VoidCallback? onDelete;

  const WarningCard({
    super.key,
    required this.warning,
    this.onDelete,
  });

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case WarningType.stairs:
        return AppStrings.warnStairs;
      case WarningType.ramp:
        return AppStrings.warnRamp;
      case WarningType.curb:
        return AppStrings.warnCurb;
      case WarningType.unevenSurface:
        return AppStrings.warnUnevenSurface;
      case WarningType.door:
        return AppStrings.warnDoor;
      case WarningType.temporaryObstacle:
        return AppStrings.warnTemporaryObstacle;
      case WarningType.other:
      default:
        return AppStrings.warnOther;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case WarningType.stairs:
        return Icons.stairs;
      case WarningType.ramp:
        return Icons.accessible_forward;
      case WarningType.curb:
        return Icons.report_problem;
      case WarningType.unevenSurface:
        return Icons.terrain;
      case WarningType.door:
        return Icons.meeting_room;
      case WarningType.temporaryObstacle:
        return Icons.construction;
      case WarningType.other:
      default:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tipoLabel = _getTipoLabel(warning.tipo);
    final date = AppDateUtils.parseIso(warning.fechaObservacion);
    final formattedDate = AppDateUtils.formatReadableDate(date);

    final semanticText =
        'Advertencia de tipo $tipoLabel. ${warning.nota}. Registrada el $formattedDate.'
        '${warning.temporal ? " Marcada como obstáculo temporal." : ""}';

    return Semantics(
      label: semanticText,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFFFFBEB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTipoIcon(warning.tipo),
                      color: const Color(0xFFD97706),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tipoLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppConstants.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Observado el: $formattedDate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (warning.temporal)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        AppStrings.warningTemporaryBadge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppConstants.statusError),
                      tooltip: 'Eliminar advertencia',
                      onPressed: onDelete,
                    ),
                ],
              ),
              if (warning.nota.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  warning.nota,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: isDark ? Colors.white70 : AppConstants.textPrimaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
