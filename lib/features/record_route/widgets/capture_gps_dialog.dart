import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../data/models/capture_model.dart';
import '../../../services/location_service.dart';
import '../../../services/stabilization.dart';
import '../../../widgets/accessible_button.dart';
import '../../../widgets/status_badge.dart';

/// Modal accesible para la captura de lecturas GPS por estabilización en fases.
class CaptureGpsDialog extends StatefulWidget {
  final int initialDuration;

  const CaptureGpsDialog({
    super.key,
    this.initialDuration = AppConstants.defaultStabilizationDurationSeconds,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    int initialDuration = AppConstants.defaultStabilizationDurationSeconds,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CaptureGpsDialog(initialDuration: initialDuration),
    );
  }

  @override
  State<CaptureGpsDialog> createState() => _CaptureGpsDialogState();
}

class _CaptureGpsDialogState extends State<CaptureGpsDialog> {
  int _selectedDuration = AppConstants.defaultStabilizationDurationSeconds;
  bool _isCapturing = false;
  StabilizationProgress? _currentProgress;
  StreamSubscription<StabilizationProgress>? _subscription;
  StabilizationResult? _finalResult;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startCapture() {
    final location = context.read<LocationService>();
    setState(() {
      _isCapturing = true;
      _finalResult = null;
      _currentProgress = null;
    });

    if (mounted) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Iniciando captura GPS de $_selectedDuration segundos. Permanece quieto en el punto.',
        TextDirection.ltr,
      );
    }

    _subscription?.cancel();
    _subscription = location
        .startStabilizationCapture(durationSeconds: _selectedDuration)
        .listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _currentProgress = progress;
        });

        if (progress.isCompleted) {
          setState(() {
            _isCapturing = false;
            _finalResult = progress.result;
          });

          final qualityStr = _finalResult != null
              ? (_finalResult!.quality == GpsQuality.good
                  ? 'Buena'
                  : _finalResult!.quality == GpsQuality.regular
                      ? 'Regular'
                      : 'Insuficiente')
              : 'Desconocida';

          SemanticsService.sendAnnouncement(
            View.of(context),
            'Captura finalizada. Se obtuvieron ${_finalResult?.validReadingsCount ?? 0} lecturas. Calidad: $qualityStr.',
            TextDirection.ltr,
          );
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la captura: $err')),
        );
      },
    );
  }

  void _cancelCapture() {
    _subscription?.cancel();
    setState(() {
      _isCapturing = false;
      _currentProgress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre superior
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Text(
                'Captura GPS de punto',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              if (!_isCapturing && _finalResult == null) ...[
                // Selección de duración
                const Text(
                  'Elige el tiempo de estabilización. La app tomará múltiples lecturas y calculará la mediana para mayor confiabilidad:',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.stabilizationDurationLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SegmentedButton<int>(
                  segments: AppConstants.stabilizationDurationsSeconds
                      .map(
                        (sec) => ButtonSegment<int>(
                          value: sec,
                          label: Text('$sec s'),
                        ),
                      )
                      .toList(),
                  selected: {_selectedDuration},
                  onSelectionChanged: (val) {
                    setState(() => _selectedDuration = val.first);
                  },
                ),
                const SizedBox(height: 24),

                AccessibleButton(
                  label: AppStrings.startCaptureButton,
                  icon: Icons.play_circle_filled,
                  type: AccessibleButtonType.primary,
                  onPressed: _startCapture,
                ),
                const SizedBox(height: 12),
                AccessibleButton(
                  label: AppStrings.captureSaveWithoutGps,
                  icon: Icons.edit_location_alt,
                  type: AccessibleButtonType.secondary,
                  onPressed: () {
                    Navigator.of(context).pop({
                      'saveWithoutGps': true,
                    });
                  },
                ),
              ] else if (_isCapturing) ...[
                // Estado de captura en progreso
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0284C7), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.capturingGpsTitle,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        AppStrings.capturingGpsSubtitle,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _currentProgress?.progressFraction ?? 0.0,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiempo restante: ${_currentProgress?.remainingSeconds ?? _selectedDuration} s',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Lecturas: ${_currentProgress?.capturedReadingsCount ?? 0}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (_currentProgress?.latestAccuracyMeters != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Última precisión: ${GeoUtils.formatAccuracy(_currentProgress?.latestAccuracyMeters)}',
                          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AccessibleButton(
                  label: AppStrings.cancel,
                  icon: Icons.stop_circle,
                  type: AccessibleButtonType.danger,
                  onPressed: _cancelCapture,
                ),
              ] else if (_finalResult != null) ...[
                // Resultado final de estabilización
                Text(
                  AppStrings.captureFinishedTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // Insignia de Calidad
                StatusBadge.gpsQuality(_finalResult!.quality, isDark: isDark),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        AppStrings.captureValidReadings,
                        '${_finalResult!.validReadingsCount}',
                      ),
                      const Divider(),
                      _buildResultRow(
                        AppStrings.captureAvgAccuracy,
                        GeoUtils.formatAccuracy(_finalResult!.averageAccuracyMeters),
                      ),
                      const Divider(),
                      _buildResultRow(
                        AppStrings.captureDispersion,
                        '${_finalResult!.dispersionMeters.toStringAsFixed(1)} metros',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (_finalResult!.quality == GpsQuality.insufficient)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppConstants.statusError),
                    ),
                    child: const Text(
                      AppStrings.captureQualityInsufficientWarning,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),

                // Acciones: Confirmar, Repetir, Descartar
                AccessibleButton(
                  label: AppStrings.captureConfirm,
                  icon: Icons.check,
                  type: AccessibleButtonType.primary,
                  onPressed: () {
                    final captureModel = CaptureModel(
                      duracionS: _selectedDuration,
                      lecturas: _finalResult!.validReadings,
                      lecturasValidas: _finalResult!.validReadingsCount,
                      precisionMediaM: _finalResult!.averageAccuracyMeters,
                      dispersionM: _finalResult!.dispersionMeters,
                      calidad: _finalResult!.quality,
                    );

                    Navigator.of(context).pop({
                      'lat': _finalResult!.estimatedLat,
                      'lon': _finalResult!.estimatedLon,
                      'captura': captureModel,
                    });
                  },
                ),
                const SizedBox(height: 10),
                AccessibleButton(
                  label: AppStrings.captureRetry,
                  icon: Icons.refresh,
                  type: AccessibleButtonType.secondary,
                  onPressed: _startCapture,
                ),
                const SizedBox(height: 10),
                AccessibleButton(
                  label: AppStrings.captureDiscard,
                  type: AccessibleButtonType.danger,
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
