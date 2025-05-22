import 'package:flutter/material.dart';
import 'package:dashboard/styles/app_dimensions.dart';

class LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;

  const LabeledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppDimensions.radiusSmall);

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.8),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingM,
          horizontal: AppDimensions.spacingM,
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: enabled
              ? theme.colorScheme.onSurface.withOpacity(0.9)
              : theme.disabledColor,
        ),
        hintStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}
