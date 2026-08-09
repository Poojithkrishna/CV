import 'package:flutter/material.dart';

/// Central brand palette for Demon Origin. All screens should pull colors from
/// [ColorScheme] (via `Theme.of(context).colorScheme`) for anything that
/// must adapt to light/dark mode; this file exists for the handful of
/// brand-fixed accents (module colors, gradients) that stay constant
/// across themes.
class AppColors {
  AppColors._();

  // Seed used to derive the Material 3 dynamic color scheme.
  static const Color seed = Color(0xFF7C4DFF);

  // Per-module accent colors, used for dashboard cards, icons and charts
  // so each life area is instantly recognizable.
  static const Color finance = Color(0xFF22C55E);
  static const Color fitness = Color(0xFFEF4444);
  static const Color habits = Color(0xFFF59E0B);
  static const Color goals = Color(0xFF3B82F6);
  static const Color creatorStudio = Color(0xFFEC4899);
  static const Color entertainment = Color(0xFF8B5CF6);
  static const Color journal = Color(0xFF14B8A6);
  static const Color calendar = Color(0xFF06B6D4);
  static const Color gamification = Color(0xFFDC2626);

  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);
  static const Color transfer = Color(0xFF3B82F6);

  static const Color darkSurface = Color(0xFF121016);
  static const Color darkSurfaceElevated = Color(0xFF1C1922);
  static const Color darkGlassBorder = Color(0x33FFFFFF);
  static const Color lightGlassBorder = Color(0x1F000000);
}
