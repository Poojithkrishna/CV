import 'package:flutter/material.dart';

/// Central brand palette for Demon Origin. All screens should pull colors from
/// [ColorScheme] (via `Theme.of(context).colorScheme`) for anything that
/// must adapt to light/dark mode; this file exists for the handful of
/// brand-fixed accents (module colors, gradients) that stay constant
/// across themes.
class AppColors {
  AppColors._();

  // Seed used to derive the Material 3 dynamic color scheme — a deeper,
  // more saturated violet than stock Material purple, so the derived
  // scheme reads as "Demon Origin" rather than a default M3 app.
  static const Color seed = Color(0xFF7C1FE0);

  // The signature Demon Origin brand duo — crimson bleeding into violet —
  // used for the app icon, splash, brand wordmark and hero glows. Anything
  // meant to feel like "the app itself" rather than a specific module
  // pulls from this pair instead of the seed-derived scheme.
  static const Color brandCrimson = Color(0xFFF43F5E);
  static const Color brandViolet = Color(0xFF7C3AED);
  static const Color brandDeepViolet = Color(0xFF4C1D95);

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

  // Deeper, violet-tinted near-blacks (rather than neutral gray-black) so
  // the whole dark theme carries a faint trace of the brand hue even on
  // plain surfaces.
  static const Color darkSurface = Color(0xFF0B0712);
  static const Color darkSurfaceElevated = Color(0xFF16101F);
  static const Color darkGlassBorder = Color(0x33FFFFFF);
  static const Color lightGlassBorder = Color(0x1F000000);

  /// A soft glow color for shadows/highlights behind emphasis elements
  /// (selected nav icon, primary buttons, hero cards) — [opacity] typically
  /// stays low (0.25–0.55) since these are meant to read as an ambient
  /// glow, not a solid fill.
  static Color glow(Color color, {double opacity = 0.45}) =>
      color.withOpacity(opacity);
}
