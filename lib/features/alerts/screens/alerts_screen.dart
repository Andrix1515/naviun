import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../data/models/route_model.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../services/location_service.dart';
import '../../../widgets/accessible_button.dart';

/// Pantalla de Alertas del sistema y diagnóstico accesible.
class AlertsScreen extends StatefulWidget {
  final VoidCallback onOpenRoutesTab;

  const AlertsScreen({super.key, required this.onOpenRoutesTab});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<RouteModel> _outdatedRoutes = [];

  @override
  void initState() {
    super.initState();
    _checkOutdatedRoutes();
  }

  Future<void> _checkOutdatedRoutes() async {
    final repo = context.read<RouteRepository>();
    final routes = await repo.getRoutes();
    final outdated = routes.where((r) => r.estaDesactualizada).toList();
    if (mounted) {
      setState(() {
        _outdatedRoutes = outdated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();

    final alerts = <Widget>[];

    // Alerta 1: GPS Desactivado
    if (location.status == LocationStatus.serviceDisabled) {
      alerts.add(
        _buildAlertCard(
          context,
          icon: Icons.location_disabled,
          title: AppStrings.alertGpsDisabledTitle,
          body: AppStrings.alertGpsDisabledBody,
          actionLabel: AppStrings.alertGpsDisabledAction,
          isError: true,
          onAction: () => location.openLocationSettings(),
        ),
      );
    }

    // Alerta 2: Permisos de Ubicación
    if (location.status == LocationStatus.permissionDenied) {
      alerts.add(
        _buildAlertCard(
          context,
          icon: Icons.security,
          title: AppStrings.alertPermissionDeniedTitle,
          body: AppStrings.alertPermissionDeniedBody,
          actionLabel: AppStrings.alertPermissionDeniedAction,
          isError: true,
          onAction: () => location.requestPermission(),
        ),
      );
    } else if (location.status == LocationStatus.permissionDeniedForever) {
      alerts.add(
        _buildAlertCard(
          context,
          icon: Icons.security_update_warning,
          title: AppStrings.alertPermissionPermanentTitle,
          body: AppStrings.alertPermissionPermanentBody,
          actionLabel: AppStrings.alertPermissionPermanentAction,
          isError: true,
          onAction: () => location.openAppSettings(),
        ),
      );
    }

    // Alerta 3: Precisión GPS baja
    if (location.status == LocationStatus.ready &&
        location.currentPosition != null &&
        location.currentPosition!.accuracy > AppConstants.maxReliableNavigationAccuracyMeters) {
      alerts.add(
        _buildAlertCard(
          context,
          icon: Icons.gps_not_fixed,
          title: AppStrings.alertAccuracyLowTitle,
          body:
              '${AppStrings.alertAccuracyLowBody} Precisión reportada actual: ±${location.currentPosition!.accuracy.toStringAsFixed(1)} m.',
          isError: false,
        ),
      );
    }

    // Alerta 4: Rutas Desactualizadas
    if (_outdatedRoutes.isNotEmpty) {
      alerts.add(
        _buildAlertCard(
          context,
          icon: Icons.warning_amber_rounded,
          title: AppStrings.alertOutdatedRoutesTitle,
          body:
              'Hay ${_outdatedRoutes.length} ruta(s) con más de 30 días sin revisión: '
              '${_outdatedRoutes.map((r) => r.nombre).take(3).join(', ')}.',
          actionLabel: 'Ver rutas en lista',
          isError: false,
          onAction: widget.onOpenRoutesTab,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alertsTitle),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await location.checkStatus();
            await _checkOutdatedRoutes();
          },
          child: alerts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 72,
                          color: AppConstants.statusSuccess,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.alertsEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Todos los sistemas y permisos necesarios están operando con normalidad.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => alerts[i],
                ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
    String? actionLabel,
    VoidCallback? onAction,
    required bool isError,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isError ? AppConstants.statusError : const Color(0xFFD97706);

    return Semantics(
      container: true,
      label: 'Alerta: $title. $body',
      child: Card(
        color: isDark
            ? (isError ? const Color(0xFF450A0A) : const Color(0xFF451A03))
            : (isError ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppConstants.textPrimaryLight,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                AccessibleButton(
                  label: actionLabel,
                  type: isError ? AccessibleButtonType.danger : AccessibleButtonType.primary,
                  minHeight: 48,
                  expandWidth: false,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
