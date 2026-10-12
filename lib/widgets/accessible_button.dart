import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../core/theme.dart';

enum AccessibleButtonType {
  primary,
  secondary,
  danger,
  gold,
}

/// Botón accesible de alto contraste con objetivo táctil garantizado >= 48x48 dp
/// y compatibilidad total con lectores de pantalla.
class AccessibleButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AccessibleButtonType type;
  final bool isLoading;
  final String? semanticHint;
  final double minHeight;
  final double? minWidth;
  final bool expandWidth;

  const AccessibleButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.type = AccessibleButtonType.primary,
    this.isLoading = false,
    this.semanticHint,
    this.minHeight = 52.0,
    this.minWidth,
    this.expandWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (type) {
      case AccessibleButtonType.primary:
        backgroundColor = isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight;
        foregroundColor = isDark ? Colors.black : Colors.white;
        break;
      case AccessibleButtonType.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight;
        borderSide = BorderSide(
          color: foregroundColor,
          width: 2.0,
        );
        break;
      case AccessibleButtonType.danger:
        backgroundColor = isDark ? const Color(0xFFEF4444) : AppConstants.statusError;
        foregroundColor = Colors.white;
        break;
      case AccessibleButtonType.gold:
        backgroundColor = AppConstants.accentGold;
        foregroundColor = Colors.black; // Dorado con texto negro cumple contraste 4.5:1
        break;
    }

    final effectiveOnPressed = (onPressed != null && !isLoading)
        ? () {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        : null;

    final childWidget = Row(
      mainAxisSize: expandWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(icon, size: 24, color: foregroundColor),
          ),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: label,
      hint: semanticHint,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight,
          minWidth: minWidth ?? (expandWidth ? double.infinity : 48.0),
        ),
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
            disabledForegroundColor: isDark ? const Color(0xFF777777) : const Color(0xFF666666),
            side: borderSide,
            elevation: type == AccessibleButtonType.primary ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: childWidget,
        ),
      ),
    );
  }
}
