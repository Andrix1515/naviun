import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import 'accessible_button.dart';

/// Diálogo modal de confirmación accesible para acciones críticas.
class AccessibleConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const AccessibleConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.isDestructive = false,
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AccessibleConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: '$title. $message',
      child: AlertDialog(
        backgroundColor: isDark ? AppConstants.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDestructive ? AppConstants.statusError : const Color(0xFFDDDDDD),
            width: isDestructive ? 2.0 : 1.0,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDestructive ? AppConstants.statusError : null,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          AccessibleButton(
            label: cancelLabel,
            type: AccessibleButtonType.secondary,
            expandWidth: false,
            minHeight: 48,
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(height: 8),
          AccessibleButton(
            label: confirmLabel,
            type: isDestructive ? AccessibleButtonType.danger : AccessibleButtonType.primary,
            expandWidth: false,
            minHeight: 48,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
