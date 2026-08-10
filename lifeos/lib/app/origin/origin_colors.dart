import 'package:flutter/material.dart';

/// Arcane Futurism's fixed palette — the single source of truth every
/// other Origin* token and every screen pulls from. Values are exactly the
/// hexes in the Demon Origin Premium Redesign Spec (v1), not approximations.
///
/// Gold and violet are accents, not base colors — see each screen's usage:
/// gold marks rare/ceremonial moments (rank-up, a hero stat), violet marks
/// ordinary interactive/selected state. Most of the UI stays obsidian and
/// text-gray.
class OriginColors {
  OriginColors._();

  static const Color background = Color(0xFF0A090C);
  static const Color surface = Color(0xFF111016);
  static const Color surfaceSecondary = Color(0xFF191322);

  static const Color textPrimary = Color(0xFFD9D5DE);
  static const Color textSecondary = Color(0xFF918B98);

  static const Color violet = Color(0xFF76558F);
  static const Color gold = Color(0xFFB89A5A);
  static const Color negative = Color(0xFFA95746);

  /// Hairline borders/dividers on panels — low-contrast on purpose (spec
  /// §8: "1dp low-contrast borders rather than thick bright outlines").
  static const Color hairline = Color(0x1FD9D5DE);
  static const Color hairlineStrong = Color(0x33D9D5DE);
}
