import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    );

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

    return base.copyWith(textTheme: merged);
  }

  static ThemeData get dark {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      useMaterial3: true,
      brightness: Brightness.dark,
    );
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
    return base.copyWith(textTheme: merged);
  }
}
