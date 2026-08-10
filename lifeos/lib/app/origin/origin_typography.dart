import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'origin_colors.dart';

/// The three-face type system (spec §4): Cinzel for ceremonial/display
/// moments only, Manrope for everything read densely, JetBrains Mono for
/// anything numeric. Never mix these roles — a paragraph in Cinzel or a
/// section title in Mono both break the hierarchy the spec asks for.
class OriginTypography {
  OriginTypography._();

  static String get display => GoogleFonts.cinzel().fontFamily!;
  static String get body => GoogleFonts.manrope().fontFamily!;
  static String get data => GoogleFonts.jetBrainsMono().fontFamily!;

  /// A ceremonial heading — screen titles, the rank name, ritual headers.
  /// Sentence case by default; call sites needing the spec's tracked-caps
  /// labels (WEALTH, CURRENT RITE) apply [eyebrow] instead.
  static TextStyle heading({double size = 22, Color? color}) => TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? OriginColors.textPrimary,
        height: 1.15,
      );

  /// A small tracked all-caps label — the spec's "WEALTH", "ORIGIN RANK"
  /// style eyebrow text. Body face, not display — these are functional
  /// labels, not ceremonial ones, and Cinzel caps at 11–12sp are illegible.
  static TextStyle eyebrow({double size = 12, Color? color}) => TextStyle(
        fontFamily: body,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color ?? OriginColors.textSecondary,
      );

  /// A tabular figure — currency, XP, sets/reps/weight, percentages.
  static TextStyle figure({double size = 20, FontWeight weight = FontWeight.w600, Color? color}) =>
      TextStyle(
        fontFamily: data,
        fontSize: size,
        fontWeight: weight,
        color: color ?? OriginColors.textPrimary,
      );
}
