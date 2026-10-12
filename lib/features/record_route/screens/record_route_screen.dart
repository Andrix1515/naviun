import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../data/models/capture_model.dart';
import '../../../data/models/route_model.dart';
import '../../../data/models/warning_model.dart';
import '../../../data/models/waypoint_model.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/settings_service.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/accessible_button.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/warning_card.dart';
import '../widgets/add_warning_dialog.dart';
import '../widgets/capture_gps_dialog.dart';
import '../widgets/support_map.dart';

/// Flujo completo para crear y registrar una nueva ruta en el campus UNCP.
class RecordRouteScreen extends StatefulWidget {
  final RouteModel? initialRoute;

  const RecordRouteScreen({super.key, this.initialRoute});

  @override
  State<RecordRouteScreen> createState() => _RecordRouteScreenState();
}

class _RecordRouteScreenState extends State<RecordRouteScreen> {
  int _currentStep = 0; // 0: Info general, 1: Puntos de control, 2: Revisión final

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _originController;
  late TextEditingController _destinationController;

  final List<WaypointModel> _waypoints = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialRoute?.nombre ?? '');
    _originController = TextEditingController(text: widget.initialRoute?.origen ?? '');
    _destinationController = TextEditingController(text: widget.initialRoute?.destino ?? '');

    if (widget.initialRoute != null) {
      _waypoints.addAll(widget.initialRoute!.puntos);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _openAddOrEditWaypointDialog({WaypointModel? existingWaypoint, int? index}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existingWaypoint?.nombre ?? '');
    final instructionCtrl = TextEditingController(text: existingWaypoint?.instruccion ?? '');
    String selectedTipo = existingWaypoint?.tipo ??
        (_waypoints.isEmpty ? WaypointType.start : WaypointType.path);

    double? lat = existingWaypoint?.latitud;
    double? lon = existingWaypoint?.longitud;
    bool isManualAdjusted = existingWaypoint?.posicionAjustadaManual ?? false;
    CaptureModel capture = existingWaypoint?.captura ?? CaptureModel.empty();
    final List<WarningModel> warnings = List.from(existingWaypoint?.advertencias ?? []);

    final tts = context.read<TtsService>();
    final settings = context.read<SettingsService>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Text(
                        existingWaypoint != null
                            ? AppStrings.editWaypointButton
                            : '${AppStrings.addWaypointButton} (${_waypoints.length + 1})',
                        style: Theme.of(ctx).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Nombre del punto
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: AppStrings.pointNameField,
                          hintText: AppStrings.pointNameHint,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa el nombre del punto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo de punto
                      DropdownButtonFormField<String>(
                        initialValue: selectedTipo,
                        decoration: const InputDecoration(labelText: AppStrings.pointTypeField),
                        items: WaypointType.all.map((t) {
                          String label;
                          switch (t) {
                            case WaypointType.start:
                              label = AppStrings.typeStart;
                              break;
                            case WaypointType.path:
                              label = AppStrings.typePath;
                              break;
                            case WaypointType.turn:
                              label = AppStrings.typeTurn;
                              break;
                            case WaypointType.door:
                              label = AppStrings.typeDoor;
                              break;
                            case WaypointType.stairs:
                              label = AppStrings.typeStairs;
                              break;
                            case WaypointType.destination:
                              label = AppStrings.typeDestination;
                              break;
                            default:
                              label = t;
                          }
                          return DropdownMenuItem(value: t, child: Text(label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedTipo = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Captura GPS
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Posición GPS',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                StatusBadge.gpsQuality(capture.calidad, isDark: isDark),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (lat != null && lon != null) ...[
                              Text('Coordenadas: ${lat!.toStringAsFixed(6)}, ${lon!.toStringAsFixed(6)}'),
                              if (isManualAdjusted)
                                const Text(
                                  AppStrings.mapAdjustedManualBadge,
                                  style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                                ),
                              Text('Lecturas válidas: ${capture.lecturasValidas} | Dispersión: ${capture.dispersionM.toStringAsFixed(1)} m'),
                            ] else
                              const Text('Sin coordenadas registradas aún.'),
                            const SizedBox(height: 12),
                            AccessibleButton(
                              label: lat != null ? 'Recapturar GPS' : 'Capturar con GPS',
                              icon: Icons.gps_fixed,
                              type: AccessibleButtonType.secondary,
                              minHeight: 48,
                              onPressed: () async {
                                final res = await CaptureGpsDialog.show(ctx);
                                if (res != null) {
                                  setSheetState(() {
                                    if (res['saveWithoutGps'] == true) {
                                      lat = null;
                                      lon = null;
                                      capture = CaptureModel.empty();
                                    } else {
                                      lat = res['lat'] as double?;
                                      lon = res['lon'] as double?;
                                      capture = res['captura'] as CaptureModel;
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Instrucción de voz
                      TextFormField(
                        controller: instructionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: AppStrings.pointInstructionField,
                          hintText: AppStrings.pointInstructionHint,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa la instrucción que escuchará el usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      AccessibleButton(
                        label: AppStrings.listenInstructionButton,
                        icon: Icons.volume_up,
                        type: AccessibleButtonType.secondary,
                        minHeight: 48,
                        onPressed: () {
                          if (instructionCtrl.text.trim().isNotEmpty) {
                            tts.speak(
                              instructionCtrl.text.trim(),
                              rate: settings.ttsRate,
                              volume: settings.ttsVolume,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Advertencias asociadas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppStrings.warningsTitle} (${warnings.length})',
                            style: Theme.of(ctx).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add_alert),
                            label: const Text('Agregar'),
                            onPressed: () async {
                              final warn = await AddWarningDialog.show(ctx);
                              if (warn != null) {
                                setSheetState(() => warnings.add(warn));
                              }
                            },
                          ),
                        ],
                      ),
                      if (warnings.isNotEmpty)
                        ...warnings.asMap().entries.map((entry) {
                          final wIdx = entry.key;
                          final w = entry.value;
                          return WarningCard(
                            warning: w,
                            onDelete: () {
                              setSheetState(() => warnings.removeAt(wIdx));
                            },
                          );
                        }),
                      const SizedBox(height: 24),

                      // Botón Guardar Punto
                      AccessibleButton(
                        label: 'Guardar este punto',
                        icon: Icons.check,
                        type: AccessibleButtonType.primary,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final newWaypoint = WaypointModel(
                              id: existingWaypoint?.id,
                              orden: index != null ? (index + 1) : (_waypoints.length + 1),
                              nombre: nameCtrl.text.trim(),
                              tipo: selectedTipo,
                              instruccion: instructionCtrl.text.trim(),
                              latitud: lat,
                              longitud: lon,
                              posicionAjustadaManual: isManualAdjusted,
                              captura: capture,
                              advertencias: warnings,
                            );

                            setState(() {
                              if (index != null) {
                                _waypoints[index] = newWaypoint;
                              } else {
                                _waypoints.add(newWaypoint);
                              }
                            });

                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _reorderWaypointsItem(int oldIndex, int newIndex) {
    setState(() {
      final item = _waypoints.removeAt(oldIndex);
      _waypoints.insert(newIndex, item);
      // Actualizar número de orden
      for (int i = 0; i < _waypoints.length; i++) {
        _waypoints[i] = _waypoints[i].copyWith(orden: i + 1);
      }
    });
  }

  Future<void> _saveRoute({required String estado}) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre para la ruta.')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (_waypoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes registrar al menos un punto de control.')),
      );
      setState(() => _currentStep = 1);
      return;
    }

    setState(() => _isSaving = true);
    final repo = context.read<RouteRepository>();

    final routeToSave = RouteModel(
      id: widget.initialRoute?.id,
      nombre: _nameController.text.trim(),
      origen: _originController.text.trim().isNotEmpty ? _originController.text.trim() : 'Origen no especificado',
      destino: _destinationController.text.trim().isNotEmpty ? _destinationController.text.trim() : 'Destino no especificado',
      estado: estado,
      esDatoDePrueba: widget.initialRoute?.esDatoDePrueba ?? false,
      creadaEn: widget.initialRoute?.creadaEn ?? DateTime.now().toIso8601String(),
      ultimaRevision: DateTime.now().toIso8601String(),
      puntos: _waypoints,
    );

    await repo.saveRoute(routeToSave);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.routeSavedSuccess),
          backgroundColor: AppConstants.primaryGreenLight,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.recordTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de Pasos Accesible
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? AppConstants.surfaceDark : const Color(0xFFF0FDF4),
              child: Row(
                children: [
                  _buildStepHeader(0, '1. Datos'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                  const SizedBox(width: 8),
                  _buildStepHeader(1, '2. Puntos (${_waypoints.length})'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                  const SizedBox(width: 8),
                  _buildStepHeader(2, '3. Revisar'),
                ],
              ),
            ),

            // Contenido según el paso activo
            Expanded(
              child: _currentStep == 0
                  ? _buildStepGeneralInfo()
                  : _currentStep == 1
                      ? _buildStepWaypoints(location, isDark)
                      : _buildStepReview(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentStep = stepIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppConstants.primaryGreenLight : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? AppConstants.primaryGreenLight
                  : isCompleted
                      ? Colors.green[700]
                      : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepGeneralInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso 1: Información general',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Define el nombre descriptivo y los extremos de la ruta para que los usuarios puedan identificarla fácilmente.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.routeNameField,
                hintText: AppStrings.routeNameHint,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre de la ruta es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: AppStrings.routeOriginField,
                hintText: AppStrings.routeOriginHint,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El origen es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: AppStrings.routeDestinationField,
                hintText: AppStrings.routeDestinationHint,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El destino es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 36),

            AccessibleButton(
              label: 'Continuar a Puntos de Control',
              icon: Icons.arrow_forward,
              type: AccessibleButtonType.primary,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWaypoints(LocationService location, bool isDark) {
    final userPos = location.currentPosition != null
        ? LatLng(location.currentPosition!.latitude, location.currentPosition!.longitude)
        : null;

    return Column(
      children: [
        // Mapa de apoyo visual (altura fija de 200 dp)
        SizedBox(
          height: 200,
          child: SupportMap(
            waypoints: _waypoints,
            userLocation: userPos,
            userAccuracy: location.currentPosition?.accuracy,
            onMapTapped: (point) {
              // Permite tocar el mapa para asignar coordenadas si se desea
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ubicación seleccionada: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),

        // Barra de acciones para agregar punto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Puntos (${_waypoints.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location),
                label: const Text('Agregar Punto'),
                onPressed: () => _openAddOrEditWaypointDialog(),
              ),
            ],
          ),
        ),

        // Lista reordenable de puntos
        Expanded(
          child: _waypoints.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pin_drop_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay puntos de control agregados.',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Camina el trayecto y pulsa "Agregar Punto" en cada tramo, giro o acceso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: AppStrings.addWaypointButton,
                          icon: Icons.add,
                          type: AccessibleButtonType.primary,
                          expandWidth: false,
                          onPressed: () => _openAddOrEditWaypointDialog(),
                        ),
                      ],
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: _waypoints.length,
                  onReorderItem: _reorderWaypointsItem,
                  itemBuilder: (ctx, i) {
                    final wp = _waypoints[i];
                    return Card(
                      key: ValueKey(wp.id),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.primaryGreenLight,
                          foregroundColor: Colors.white,
                          child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(
                          wp.nombre,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wp.instruccion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusBadge.gpsQuality(wp.captura.calidad, isDark: isDark),
                                if (wp.advertencias.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${wp.advertencias.length} advertencia(s)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Editar punto',
                              onPressed: () => _openAddOrEditWaypointDialog(
                                existingWaypoint: wp,
                                index: i,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppConstants.statusError),
                              tooltip: 'Eliminar punto',
                              onPressed: () {
                                setState(() => _waypoints.removeAt(i));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Botón para continuar a la revisión
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: AccessibleButton(
                  label: 'Atrás',
                  type: AccessibleButtonType.secondary,
                  onPressed: () => setState(() => _currentStep = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AccessibleButton(
                  label: 'Revisar Ruta',
                  type: AccessibleButtonType.primary,
                  onPressed: () => setState(() => _currentStep = 2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepReview(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 3: Revisión final',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa los datos registrados antes de guardar la ruta en tu dispositivo:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 18),

          // Resumen de la ruta
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Sin nombre',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Origen: ${_originController.text}'),
                  Text('Destino: ${_destinationController.text}'),
                  Text('Total de puntos de control: ${_waypoints.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de advertencias de seguridad encontradas
          finalWarningsList(),
          const SizedBox(height: 28),

          // Acciones de guardado
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else ...[
            AccessibleButton(
              label: AppStrings.saveAsPendingValidation,
              icon: Icons.check_circle,
              type: AccessibleButtonType.primary,
              minHeight: 56,
              onPressed: () => _saveRoute(estado: RouteStatus.pendingValidation),
            ),
            const SizedBox(height: 14),
            AccessibleButton(
              label: AppStrings.saveAsDraft,
              icon: Icons.save_outlined,
              type: AccessibleButtonType.secondary,
              minHeight: 52,
              onPressed: () => _saveRoute(estado: RouteStatus.draft),
            ),
            const SizedBox(height: 14),
            AccessibleButton(
              label: 'Volver a editar puntos',
              type: AccessibleButtonType.secondary,
              onPressed: () => setState(() => _currentStep = 1),
            ),
          ],
        ],
      ),
    );
  }

  Widget finalWarningsList() {
    final allWarnings = <WarningModel>[];
    for (final wp in _waypoints) {
      allWarnings.addAll(wp.advertencias);
    }

    if (allWarnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('No se registraron advertencias manuales.'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advertencias registradas en esta ruta (${allWarnings.length}):',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...allWarnings.map((w) => WarningCard(warning: w)),
      ],
    );
  }
}
