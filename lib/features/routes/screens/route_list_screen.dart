import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/route_model.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../widgets/accessible_button.dart';
import '../../../widgets/accessible_dialog.dart';
import '../../../widgets/status_badge.dart';

/// Pantalla de lista de rutas con buscador, exportación y gestión.
class RouteListScreen extends StatefulWidget {
  final Function(RouteModel) onStartNavigation;
  final Function(RouteModel)? onEditRoute;
  final VoidCallback onNewRoute;

  const RouteListScreen({
    super.key,
    required this.onStartNavigation,
    this.onEditRoute,
    required this.onNewRoute,
  });

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  List<RouteModel> _routes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    final repo = context.read<RouteRepository>();
    final routes = await repo.getRoutes();
    if (mounted) {
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    }
  }

  List<RouteModel> get _filteredRoutes {
    if (_searchQuery.trim().isEmpty) return _routes;
    final query = _searchQuery.toLowerCase().trim();
    return _routes.where((r) {
      final nameMatches = r.nombre.toLowerCase().contains(query);
      final originMatches = r.origen.toLowerCase().contains(query);
      final destMatches = r.destino.toLowerCase().contains(query);
      return nameMatches || originMatches || destMatches;
    }).toList();
  }

  Future<void> _deleteRoute(RouteModel route) async {
    final confirmed = await AccessibleConfirmDialog.show(
      context,
      title: AppStrings.routeDeleteConfirmTitle,
      message: '${AppStrings.routeDeleteConfirmMessage} Se borrará: "${route.nombre}".',
      confirmLabel: AppStrings.delete,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final repo = context.read<RouteRepository>();
      await repo.deleteRoute(route.id);
      await _loadRoutes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.routeDeleteSuccess),
            backgroundColor: AppConstants.statusError,
          ),
        );
      }
    }
  }

  Future<void> _exportRoute(RouteModel route) async {
    final repo = context.read<RouteRepository>();
    final jsonStr = await repo.exportRouteJson(route);
    await SharePlus.instance.share(
      ShareParams(
        text: jsonStr,
        subject: 'Ruta Naviun UNCP: ${route.nombre}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredRoutes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.routesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Registrar nueva ruta',
            onPressed: widget.onNewRoute,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Campo de búsqueda accesible
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Semantics(
                label: 'Buscar rutas en el campus',
                textField: true,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.routesSearchPlaceholder,
                    prefixIcon: const Icon(Icons.search, size: 24),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),
            ),

            // Contenido de la lista
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.route_outlined,
                                  size: 64,
                                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? AppStrings.routesEmptySearch
                                      : AppStrings.homeNoRoutesTitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 16),
                                  AccessibleButton(
                                    label: AppStrings.homeRecordRoute,
                                    icon: Icons.add,
                                    type: AccessibleButtonType.primary,
                                    expandWidth: false,
                                    onPressed: widget.onNewRoute,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: filtered.length,
                          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                          itemBuilder: (ctx, index) {
                            final route = filtered[index];
                            final reviewDate = AppDateUtils.parseIso(route.ultimaRevision);
                            final formattedReview = AppDateUtils.formatReadableDate(reviewDate);

                            return Semantics(
                              container: true,
                              label:
                                  'Ruta: ${route.nombre}. '
                                  'De ${route.origen} a ${route.destino}. '
                                  'Tiene ${route.puntos.length} puntos de control. '
                                  'Estado: ${route.estadoActual}. '
                                  '${route.esDatoDePrueba ? "Datos de prueba." : ""}',
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Fila de encabezado con nombre y badges
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              route.nombre,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            tooltip: AppStrings.routeOptionsButton,
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (val) {
                                              if (val == 'export') {
                                                _exportRoute(route);
                                              } else if (val == 'delete') {
                                                _deleteRoute(route);
                                              } else if (val == 'edit') {
                                                if (widget.onEditRoute != null) {
                                                  widget.onEditRoute!(route);
                                                }
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              if (widget.onEditRoute != null)
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit, size: 20),
                                                      SizedBox(width: 10),
                                                      Text(AppStrings.routeEdit),
                                                    ],
                                                  ),
                                                ),
                                              const PopupMenuItem(
                                                value: 'export',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.share, size: 20),
                                                    SizedBox(width: 10),
                                                    Text(AppStrings.routeExport),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, color: AppConstants.statusError, size: 20),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      AppStrings.routeDelete,
                                                      style: TextStyle(color: AppConstants.statusError),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Badges de estado
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          StatusBadge.routeStatus(route.estadoActual, isDark: isDark),
                                          if (route.esDatoDePrueba)
                                            StatusBadge.testData(isDark: isDark),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Origen y Destino
                                      Row(
                                        children: [
                                          const Icon(Icons.trip_origin, size: 16, color: AppConstants.primaryGreenLight),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${AppStrings.routeOriginLabel} ${route.origen}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: AppConstants.accentGold),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${AppStrings.routeDestinationLabel} ${route.destino}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Cantidad de puntos y última revisión
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${AppStrings.routeWaypointsCount} ${route.puntos.length}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: isDark ? Colors.grey[300] : AppConstants.textSecondaryLight,
                                            ),
                                          ),
                                          Text(
                                            '${AppStrings.routeLastReview} $formattedReview',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark ? Colors.grey[400] : const Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Botón Iniciar Ruta
                                      AccessibleButton(
                                        label: AppStrings.routeStartButton,
                                        icon: Icons.navigation_outlined,
                                        type: AccessibleButtonType.primary,
                                        minHeight: 50,
                                        semanticHint: 'Inicia el guiado paso a paso para la ruta ${route.nombre}',
                                        onPressed: () => widget.onStartNavigation(route),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
