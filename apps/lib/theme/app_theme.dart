import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seed = Colors.teal;

  static ThemeData get light => lightFrom(ColorScheme.fromSeed(seedColor: seed));

  static ThemeData get dark => darkFrom(ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark));

  static ThemeData lightFrom(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    // Body: Noto Sans Khmer; Headings/Titles: Kantumruy
    final bodyText = GoogleFonts.notoSansKhmerTextTheme(base.textTheme);
    final heading = GoogleFonts.kantumruyProTextTheme(base.textTheme);

    final merged = bodyText.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: merged,
      inputDecorationTheme: _inputDecorationTheme(scheme),
      filledButtonTheme: _filledButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      elevatedButtonTheme: _elevatedButtonTheme(scheme),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: merged.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: scheme.surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: merged.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: scheme.secondaryContainer.withOpacity(0.65),
        backgroundColor: scheme.surface,
        elevation: 0,
        height: 72,
        labelTextStyle: MaterialStateProperty.all(merged.labelMedium),
      ),
    );
  }

  static ThemeData darkFrom(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: Brightness.dark);
    final bodyText = GoogleFonts.notoSansKhmerTextTheme(base.textTheme);
    final heading = GoogleFonts.kantumruyProTextTheme(base.textTheme);
    final merged = bodyText.copyWith(
      displayLarge: heading.displayLarge,
      displayMedium: heading.displayMedium,
      displaySmall: heading.displaySmall,
      headlineLarge: heading.headlineLarge,
      headlineMedium: heading.headlineMedium,
      headlineSmall: heading.headlineSmall,
      titleLarge: heading.titleLarge,
      titleMedium: heading.titleMedium,
      titleSmall: heading.titleSmall,
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: merged,
      inputDecorationTheme: _inputDecorationTheme(scheme),
      filledButtonTheme: _filledButtonTheme(scheme),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
      elevatedButtonTheme: _elevatedButtonTheme(scheme),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: merged.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: scheme.surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: merged.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: scheme.secondaryContainer.withOpacity(0.65),
        backgroundColor: scheme.surface,
        elevation: 0,
        height: 72,
        labelTextStyle: MaterialStateProperty.all(merged.labelMedium),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme) => InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 1.5)),
      );

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme scheme) => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
