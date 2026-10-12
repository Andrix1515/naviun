import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/warning_model.dart';
import '../../../widgets/accessible_button.dart';

/// Diálogo accesible para registrar una advertencia manual para un punto de control.
class AddWarningDialog extends StatefulWidget {
  final WarningModel? initialWarning;

  const AddWarningDialog({super.key, this.initialWarning});

  static Future<WarningModel?> show(BuildContext context, {WarningModel? initialWarning}) {
    return showDialog<WarningModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddWarningDialog(initialWarning: initialWarning),
    );
  }

  @override
  State<AddWarningDialog> createState() => _AddWarningDialogState();
}

class _AddWarningDialogState extends State<AddWarningDialog> {
  late String _selectedTipo;
  late TextEditingController _noteController;
  late DateTime _fechaObservacion;
  late bool _isTemporal;

  @override
  void initState() {
    super.initState();
    _selectedTipo = widget.initialWarning?.tipo ?? WarningType.stairs;
    _noteController = TextEditingController(text: widget.initialWarning?.nota ?? '');
    _fechaObservacion = AppDateUtils.parseIso(widget.initialWarning?.fechaObservacion) ?? DateTime.now();
    _isTemporal = widget.initialWarning?.temporal ?? false;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Registrar advertencia manual para el tramo',
      child: AlertDialog(
        title: const Text(AppStrings.addWarningButton),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tipo de advertencia
              Text(
                AppStrings.warningTypeField,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedTipo,
                isExpanded: true,
                items: WarningType.all.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(_getTipoLabel(tipo)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTipo = val;
                      if (val == WarningType.temporaryObstacle) {
                        _isTemporal = true;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Nota detallada
              Text(
                AppStrings.warningNoteField,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: AppStrings.warningNoteHint,
                ),
              ),
              const SizedBox(height: 16),

              // Fecha de observación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.warningDateObservedField,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.formatReadableDate(_fechaObservacion),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : AppConstants.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaObservacion,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _fechaObservacion = picked);
                      }
                    },
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Switch Obstáculo Temporal
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  AppStrings.warningTemporaryField,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                value: _isTemporal,
                onChanged: (val) => setState(() => _isTemporal = val),
              ),
            ],
          ),
        ),
        actions: [
          AccessibleButton(
            label: AppStrings.cancel,
            type: AccessibleButtonType.secondary,
            expandWidth: false,
            minHeight: 48,
            onPressed: () => Navigator.of(context).pop(null),
          ),
          const SizedBox(height: 8),
          AccessibleButton(
            label: AppStrings.save,
            type: AccessibleButtonType.primary,
            expandWidth: false,
            minHeight: 48,
            onPressed: () {
              final warning = WarningModel(
                tipo: _selectedTipo,
                nota: _noteController.text.trim(),
                fechaObservacion: _fechaObservacion.toIso8601String(),
                temporal: _isTemporal,
                estadoRevision: 'revisada',
              );
              Navigator.of(context).pop(warning);
            },
          ),
        ],
      ),
    );
  }
}
