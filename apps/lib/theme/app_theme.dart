import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light blue colors for a fresh, modern look
  static const Color seed = Color(0xFF4FC3F7); // Light blue
  static const Color primaryBlue = Color(0xFF4FC3F7);
  static const Color secondaryBlue = Color(0xFF81D4FA);
  static const Color gradientStart = Color(0xFF4FC3F7);
  static const Color gradientEnd = Color(0xFF81D4FA);

  static ThemeData get light =>
      lightFrom(ColorScheme.fromSeed(seedColor: seed));

  static ThemeData get dark => darkFrom(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
  );

  // Build a Material 3 theme using FlexColorScheme.
  static ThemeData lightFrom(ColorScheme? dynamicScheme) {
    final theme = FlexThemeData.light(
      // Use the light blue seed color directly for consistent blue theming
      colorScheme: dynamicScheme ?? ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      subThemesData: const FlexSubThemesData(
        defaultRadius: 20,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 16,
        chipRadius: 16,
        navigationBarHeight: 72,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationBarIndicatorOpacity: 0.65,
        elevatedButtonRadius: 16,
        filledButtonRadius: 16,
        outlinedButtonRadius: 16,
        segmentedButtonRadius: 16,
        textButtonRadius: 16,
        popupMenuRadius: 16,
        dialogRadius: 24,
        bottomSheetRadius: 24,
        cardRadius: 24,
      ),
      // Make surfaces slightly more elevated on light theme for depth.
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 10,
    );

    return _withTypography(theme);
  }

  static ThemeData darkFrom(ColorScheme? dynamicScheme) {
    final theme = FlexThemeData.dark(
      colorScheme: dynamicScheme ?? ColorScheme.fromSeed(
        seedColor: seed, 
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      subThemesData: const FlexSubThemesData(
        defaultRadius: 20,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 16,
        chipRadius: 16,
        navigationBarHeight: 72,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationBarIndicatorOpacity: 0.65,
        elevatedButtonRadius: 16,
        filledButtonRadius: 16,
        outlinedButtonRadius: 16,
        segmentedButtonRadius: 16,
        textButtonRadius: 16,
        popupMenuRadius: 16,
        dialogRadius: 24,
        bottomSheetRadius: 24,
        cardRadius: 24,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 12,
    );

    return _withTypography(theme, dark: true);
  }

  // Apply GoogleFonts (Khmer friendly) typography atop the base theme.
  static ThemeData _withTypography(ThemeData base, {bool dark = false}) {
    final body = GoogleFonts.notoSansKhmerTextTheme(base.textTheme);
    final head = GoogleFonts.kantumruyProTextTheme(base.textTheme);
    final text = body.copyWith(
      displayLarge: head.displayLarge,
      displayMedium: head.displayMedium,
      displaySmall: head.displaySmall,
      headlineLarge: head.headlineLarge,
      headlineMedium: head.headlineMedium,
      headlineSmall: head.headlineSmall,
      titleLarge: head.titleLarge,
      titleMedium: head.titleMedium,
      titleSmall: head.titleSmall,
    );

    return base.copyWith(textTheme: text);
  }
}
