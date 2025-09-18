import 'package:flutter/material.dart';

class AppFormStyles {
  const AppFormStyles._();

  static InputDecoration fieldDecoration(
    BuildContext context, {
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior:
          label != null ? FloatingLabelBehavior.never : FloatingLabelBehavior.auto,
      filled: true,
      fillColor: scheme.surfaceVariant
          .withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
