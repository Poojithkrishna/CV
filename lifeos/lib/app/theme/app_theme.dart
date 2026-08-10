import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../origin/origin_colors.dart';
import '../origin/origin_shapes.dart';
import '../origin/origin_typography.dart';

/// Builds the light and dark Material 3 themes for Demon Origin, sourcing
/// every color from [OriginColors] — the app's design tokens live in one
/// place (`lib/app/origin/`), not scattered per-screen.
///
/// The app is dark-mode-first (it's a personal, always-on-phone tool used
/// day and night) but a light theme is fully supported for daytime use.
class AppTheme {
  AppTheme._();

  /// The mythic/gothic display face used only for brand moments (the
  /// "DEMON ORIGIN" wordmark, rank-up celebrations, ceremonial headings)
  /// — never for dense body or list text, where its inscriptional caps
  /// hurt legibility at small sizes. See `OriginTypography.heading`.
  static String get displayFontFamily => OriginTypography.display;

  /// The tabular data face for stat numbers and HUD-style eyebrow labels.
  /// See `OriginTypography.figure`/`eyebrow`.
  static String get hudFontFamily => OriginTypography.data;

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Built explicitly rather than via `ColorScheme.fromSeed` — a seed
    // with zero chroma still leaves Material's tonal palette algorithm to
    // invent a hue for secondary/tertiary roles (this bit the app once
    // already, via radio buttons/sliders/the FAB going faintly blue).
    // Every role below is a literal Origin token instead, and
    // `surfaceTint` is pinned to transparent so Material 3's elevation
    // tint overlay (which defaults to tinting elevated surfaces with
    // `primary`) can't reintroduce an unwanted hue on cards/dialogs.
    final ColorScheme colorScheme = isDark
        ? const ColorScheme.dark(
            primary: OriginColors.accent,
            onPrimary: Color(0xFF1A1A1A),
            primaryContainer: OriginColors.surfaceSecondary,
            onPrimaryContainer: OriginColors.textPrimary,
            secondary: OriginColors.accent,
            onSecondary: Color(0xFF1A1A1A),
            secondaryContainer: OriginColors.surfaceSecondary,
            onSecondaryContainer: OriginColors.textPrimary,
            tertiary: OriginColors.textSecondary,
            onTertiary: Color(0xFF1A1A1A),
            error: OriginColors.negative,
            onError: Color(0xFFF5F2F8),
            surface: OriginColors.surface,
            onSurface: OriginColors.textPrimary,
            onSurfaceVariant: OriginColors.textSecondary,
            surfaceContainerHigh: OriginColors.surfaceSecondary,
            outline: Color(0xFF3A3640),
            outlineVariant: Color(0xFF242029),
            surfaceTint: Colors.transparent,
          )
        : const ColorScheme.light(
            primary: Color(0xFF2A2A2A),
            onPrimary: Color(0xFFFAFAFA),
            primaryContainer: Color(0xFFE3E3E3),
            onPrimaryContainer: Color(0xFF1A1A1A),
            secondary: Color(0xFF2A2A2A),
            onSecondary: Color(0xFFFAFAFA),
            secondaryContainer: Color(0xFFE3E3E3),
            onSecondaryContainer: Color(0xFF1A1A1A),
            tertiary: Color(0xFF5C5C5C),
            onTertiary: Color(0xFFFAFAFA),
            error: OriginColors.negative,
            onError: Color(0xFFFAFAFA),
            surface: Color(0xFFFBFAFF),
            onSurface: Color(0xFF1A1A1A),
            onSurfaceVariant: Color(0xFF5C5C5C),
            surfaceContainerHigh: Color(0xFFEDEDF2),
            outline: Color(0xFFBDBDBD),
            outlineVariant: Color(0xFFDADADA),
            surfaceTint: Colors.transparent,
          );

    final TextTheme textTheme = GoogleFonts.manropeTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // Dark mode leaves this transparent so AmbientBackground (mounted
      // once above the router — see DemonOriginApp) shows through on every
      // screen; light mode keeps a plain opaque surface.
      scaffoldBackgroundColor: isDark ? Colors.transparent : colorScheme.surface,
      textTheme: textTheme,
      fontFamily: OriginTypography.body,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? OriginColors.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: OriginShapes.panel(
          side: BorderSide(
            color: isDark ? OriginColors.hairline : const Color(0x1F1A1A1A),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OriginShapes.radiusLg),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OriginShapes.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OriginShapes.radiusLg),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 4,
          shadowColor: OriginColors.accent.withOpacity(0.4),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OriginShapes.radiusLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? OriginColors.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(OriginShapes.radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? OriginColors.surface : Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
        color: isDark ? OriginColors.surface : Colors.white,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? OriginColors.hairline : const Color(0x1F1A1A1A),
        space: 1,
      ),
    );
  }
}
