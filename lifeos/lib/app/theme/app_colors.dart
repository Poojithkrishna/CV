import 'package:flutter/material.dart';

/// Central brand palette for Demon Origin. All screens should pull colors from
/// [ColorScheme] (via `Theme.of(context).colorScheme`) for anything that
/// must adapt to light/dark mode; this file exists for the handful of
/// brand-fixed accents (module colors, gradients) that stay constant
/// across themes.
///
/// The palette is deliberately achromatic — black, grey and white/silver,
/// taken directly from the app icon's own artwork — rather than an invented
/// hue. A seed color still has to exist for Material 3's `ColorScheme.
/// fromSeed` (it needs *some* color to derive tones from), so [seed] is a
/// true neutral gray, which keeps the derived scheme's accents close to
/// grayscale too instead of introducing a hue of its own.
class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF8A8A8A);

  // The signature Demon Origin brand duo — bright silver fading to a
  // darker graphite — used for the app icon, splash, brand wordmark and
  // hero glows. Anything meant to feel like "the app itself" rather than a
  // specific module pulls from this trio instead of the seed-derived
  // scheme.
  static const Color brandBright = Color(0xFFF2F2F2);
  static const Color brandMid = Color(0xFFA6A6A6);
  static const Color brandDeep = Color(0xFF454545);

  // Every module shares this one neutral tone by design — the app tells
  // modules apart by icon and label, not by giving each one its own hue
  // (see ModuleSummaryCard). Kept as separate named constants so call
  // sites stay self-documenting about which module they mean.
  static const Color _moduleGray = Color(0xFFAFAFAF);
  static const Color finance = _moduleGray;
  static const Color fitness = _moduleGray;
  static const Color habits = _moduleGray;
  static const Color goals = _moduleGray;
  static const Color creatorStudio = _moduleGray;
  static const Color entertainment = _moduleGray;
  static const Color journal = _moduleGray;
  static const Color calendar = _moduleGray;
  static const Color gamification = _moduleGray;

  // Money direction is conveyed by the arrow icon (see TransactionType)
  // plus brightness here — bright for inflow, muted for outflow — rather
  // than a green/red hue, so it stays inside the grayscale palette.
  static const Color income = Color(0xFFF2F2F2);
  static const Color expense = Color(0xFF8E8E8E);
  static const Color transfer = Color(0xFFBDBDBD);

  static const Color darkSurface = Color(0xFF0A0A0A);
  static const Color darkSurfaceElevated = Color(0xFF171717);
  static const Color darkGlassBorder = Color(0x33FFFFFF);
  static const Color lightGlassBorder = Color(0x1F000000);

  /// A soft glow color for shadows/highlights behind emphasis elements
  /// (selected nav icon, primary buttons, hero cards) — [opacity] typically
  /// stays low (0.25–0.55) since these are meant to read as an ambient
  /// glow, not a solid fill.
  static Color glow(Color color, {double opacity = 0.45}) =>
      color.withOpacity(opacity);
}
