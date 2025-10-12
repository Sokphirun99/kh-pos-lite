import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seed = Colors.teal;

  static ThemeData get light => lightFrom(ColorScheme.fromSeed(seedColor: seed));

  static ThemeData get dark => darkFrom(ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark));

  // Build a Material 3 theme using FlexColorScheme.
  static ThemeData lightFrom(ColorScheme? dynamicScheme) {
    final theme = FlexThemeData.light(
      // Prefer dynamic scheme when available (Android 12+), otherwise seed.
      colorScheme: dynamicScheme,
      scheme: dynamicScheme == null ? FlexScheme.tealM3 : null,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      subThemesData: const FlexSubThemesData(
        defaultRadius: 16,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12,
        chipRadius: 10,
        navigationBarHeight: 72,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationBarIndicatorOpacity: 0.65,
        elevatedButtonRadius: 12,
        filledButtonRadius: 12,
        outlinedButtonRadius: 12,
        segmentedButtonRadius: 12,
        textButtonRadius: 12,
        popupMenuRadius: 12,
        dialogRadius: 20,
        bottomSheetRadius: 20,
        cardRadius: 20,
      ),
      // Make surfaces slightly more elevated on light theme for depth.
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 10,
    );

    return _withTypography(theme);
  }

  static ThemeData darkFrom(ColorScheme? dynamicScheme) {
    final theme = FlexThemeData.dark(
      colorScheme: dynamicScheme,
      scheme: dynamicScheme == null ? FlexScheme.tealM3 : null,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      subThemesData: const FlexSubThemesData(
        defaultRadius: 16,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12,
        chipRadius: 10,
        navigationBarHeight: 72,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationBarIndicatorOpacity: 0.65,
        elevatedButtonRadius: 12,
        filledButtonRadius: 12,
        outlinedButtonRadius: 12,
        segmentedButtonRadius: 12,
        textButtonRadius: 12,
        popupMenuRadius: 12,
        dialogRadius: 20,
        bottomSheetRadius: 20,
        cardRadius: 20,
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

    return base.copyWith(
      textTheme: text,
    );
  }
}
