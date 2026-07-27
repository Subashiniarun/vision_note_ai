import 'package:flutter/material.dart';

class AppColors {
  // User-specified brand colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color tertiary = Color(0xFF3B82F6);
  static const Color neutral = Color(0xFF64748B);

  // Surface
  static const Color surface = Color(0xFFf8f9ff);
  static const Color surfaceDim = Color(0xFFcbdbf5);
  static const Color surfaceBright = Color(0xFFf8f9ff);
  static const Color surfaceContainerLowest = Color(0xFFffffff);
  static const Color surfaceContainerLow = Color(0xFFeff4ff);
  static const Color surfaceContainer = Color(0xFFe5eeff);
  static const Color surfaceContainerHigh = Color(0xFFdce9ff);
  static const Color surfaceContainerHighest = Color(0xFFd3e4fe);

  // On-surface
  static const Color onSurface = Color(0xFF0b1c30);
  static const Color onSurfaceVariant = Color(0xFF464554);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFeaf1ff);

  // Outline
  static const Color outline = Color(0xFF767586);
  static const Color outlineVariant = Color(0xFFc7c4d7);

  // Primary
  static const Color onPrimary = Color(0xFFffffff);
  static const Color primaryContainer = Color(0xFF6063ee);
  static const Color onPrimaryContainer = Color(0xFFfffbff);
  static const Color inversePrimary = Color(0xFFc0c1ff);
  static const Color primaryFixed = Color(0xFFe1e0ff);
  static const Color primaryFixedDim = Color(0xFFc0c1ff);
  static const Color onPrimaryFixed = Color(0xFF07006c);
  static const Color onPrimaryFixedVariant = Color(0xFF2f2ebe);

  // Secondary
  static const Color onSecondary = Color(0xFFffffff);
  static const Color secondaryContainer = Color(0xFF8455ef);
  static const Color onSecondaryContainer = Color(0xFFfffbff);
  static const Color secondaryFixed = Color(0xFFe9ddff);
  static const Color secondaryFixedDim = Color(0xFFd0bcff);
  static const Color onSecondaryFixed = Color(0xFF23005c);
  static const Color onSecondaryFixedVariant = Color(0xFF5516be);

  // Tertiary
  static const Color onTertiary = Color(0xFFffffff);
  static const Color tertiaryContainer = Color(0xFF2170e4);
  static const Color onTertiaryContainer = Color(0xFFfefcff);
  static const Color tertiaryFixed = Color(0xFFd8e2ff);
  static const Color tertiaryFixedDim = Color(0xFFadc6ff);
  static const Color onTertiaryFixed = Color(0xFF001a42);
  static const Color onTertiaryFixedVariant = Color(0xFF004395);

  // Error
  static const Color error = Color(0xFFba1a1a);
  static const Color onError = Color(0xFFffffff);
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);

  // Background
  static const Color background = Color(0xFFf8f9ff);
  static const Color onBackground = Color(0xFF0b1c30);

  // AI gradient
  static const List<Color> aiGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
  ];

  // Dark theme overrides
  static const Color darkSurface = Color(0xFF111318);
  static const Color darkSurfaceContainer = Color(0xFF1E2030);
  static const Color darkOnSurface = Color(0xFFE2E2F0);
  static const Color darkOnSurfaceVariant = Color(0xFFC4C6D0);
  static const Color darkOutline = Color(0xFF8E8E9A);
  static const Color darkPrimary = Color(0xFFA5A6FF);
  static const Color darkSecondary = Color(0xFFC4A0FF);
  static const Color darkTertiary = Color(0xFF8ABAFF);

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    inversePrimary: inversePrimary,
  );

  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: Color(0xFF1A1B2E),
    primaryContainer: Color(0xFF3E40A0),
    onPrimaryContainer: Color(0xFFE1E0FF),
    secondary: darkSecondary,
    onSecondary: Color(0xFF2D1B4E),
    secondaryContainer: Color(0xFF5E3A8E),
    onSecondaryContainer: Color(0xFFE9DDFF),
    tertiary: darkTertiary,
    onTertiary: Color(0xFF003366),
    tertiaryContainer: Color(0xFF1E5AA8),
    onTertiaryContainer: Color(0xFFD8E2FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: const Color(0xFF2A2D3E),
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: const Color(0xFF46464F),
    inverseSurface: const Color(0xFFE2E2F0),
    inversePrimary: primary,
  );
}
