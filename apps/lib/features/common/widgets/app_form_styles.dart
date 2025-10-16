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
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: label != null
          ? FloatingLabelBehavior.never
          : FloatingLabelBehavior.auto,
      // Let theme subthemes (FlexColorScheme) define fill, radius, and paddings.
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }
}
