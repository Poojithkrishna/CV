import 'package:flutter/material.dart';

/// Arcane Futurism's fixed palette — the single source of truth every
/// other Origin* token and every screen pulls from.
///
/// Kept intentionally close to the app icon's own black/white/grey
/// artwork rather than the redesign spec's violet/gold accent pair — per
/// direct feedback, the palette should read as an extension of the icon,
/// not an invented brand color. [accent] is a near-white silver used for
/// ordinary interactive/selected state (buttons, the selected nav glyph,
/// progress fills); [gold] is kept defined but unused for now, reserved in
/// case a future rare/ceremonial moment (e.g. a rank-up flash) calls for a
/// single deliberate exception — it must stay rare if it's ever used.
class OriginColors {
  OriginColors._();

  static const Color background = Color(0xFF0A090C);
  static const Color surface = Color(0xFF111016);
  static const Color surfaceSecondary = Color(0xFF191322);

  static const Color textPrimary = Color(0xFFD9D5DE);
  static const Color textSecondary = Color(0xFF918B98);

  static const Color accent = Color(0xFFEDEBEF);
  static const Color gold = Color(0xFFB89A5A);
  static const Color negative = Color(0xFFA95746);

  /// Hairline borders/dividers on panels — low-contrast on purpose (spec
  /// §8: "1dp low-contrast borders rather than thick bright outlines").
  static const Color hairline = Color(0x1FD9D5DE);
  static const Color hairlineStrong = Color(0x33D9D5DE);
}
