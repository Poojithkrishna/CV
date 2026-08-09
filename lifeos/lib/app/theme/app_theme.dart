import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark Material 3 themes for Demon Origin.
///
/// The app is dark-mode-first (it's a personal, always-on-phone tool used
/// day and night) but a light theme is fully supported for daytime use.
class AppTheme {
  AppTheme._();

  /// The mythic/gothic display face used only for brand moments (the
  /// "DEMON ORIGIN" wordmark, rank-up celebrations) — never for dense body
  /// or list text, where its inscriptional caps hurt legibility at small
  /// sizes. See `BrandWordmark`.
  static String get displayFontFamily => GoogleFonts.cinzel().fontFamily!;

  /// The angular sci-fi-HUD face for "readout" moments — stat numbers,
  /// section eyebrows, anything meant to feel like a targeting display
  /// rather than prose. Pairs the mythic wordmark with a futuristic
  /// counterpart rather than picking one mood over the other.
  static String get hudFontFamily => GoogleFonts.rajdhani().fontFamily!;

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Built explicitly rather than via `ColorScheme.fromSeed` — a
    // seed with zero chroma (a true gray) still leaves Material's tonal
    // palette algorithm to pick an arbitrary hue for secondary/tertiary
    // roles, which is where a faint, unwanted blue crept into radio
    // buttons, sliders and the FAB. Every role below is a literal
    // black/grey/white value instead, and `surfaceTint` is pinned to
    // transparent so Material 3's elevation tint overlay (which defaults
    // to tinting elevated surfaces with `primary`) can't reintroduce a
    // hue on cards, dialogs or the bottom sheet.
    final ColorScheme colorScheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFFF2F2F2),
            onPrimary: Color(0xFF141414),
            primaryContainer: Color(0xFF2A2A2A),
            onPrimaryContainer: Color(0xFFF2F2F2),
            secondary: Color(0xFFBDBDBD),
            onSecondary: Color(0xFF141414),
            secondaryContainer: Color(0xFF262626),
            onSecondaryContainer: Color(0xFFF2F2F2),
            tertiary: Color(0xFF9E9E9E),
            onTertiary: Color(0xFF141414),
            surface: AppColors.darkSurface,
            onSurface: Color(0xFFF2F2F2),
            onSurfaceVariant: Color(0xFFA6A6A6),
            surfaceContainerHigh: Color(0xFF1F1F1F),
            outline: Color(0xFF4A4A4A),
            outlineVariant: Color(0xFF2E2E2E),
            surfaceTint: Colors.transparent,
          )
        : const ColorScheme.light(
            primary: Color(0xFF262626),
            onPrimary: Color(0xFFFAFAFA),
            primaryContainer: Color(0xFFE3E3E3),
            onPrimaryContainer: Color(0xFF141414),
            secondary: Color(0xFF5C5C5C),
            onSecondary: Color(0xFFFAFAFA),
            secondaryContainer: Color(0xFFE9E9E9),
            onSecondaryContainer: Color(0xFF141414),
            tertiary: Color(0xFF757575),
            onTertiary: Color(0xFFFAFAFA),
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
      fontFamily: GoogleFonts.manrope().fontFamily,
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
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? AppColors.darkGlassBorder
                : AppColors.lightGlassBorder,
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
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 6,
          shadowColor: AppColors.brandMid.withOpacity(0.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        elevation: 0,
        height: 64,
        // Icon-only nav — labels stay attached for accessibility/tooltips
        // but never paint, matching a HUD dock rather than a labeled tab
        // bar.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        surfaceTintColor: Colors.transparent,
        // A soft silver glow pill behind the selected icon instead of
        // Material's flat default indicator — the one piece of chrome
        // visible on every screen, so it carries a lot of the "premium"
        // impression.
        indicatorColor: AppColors.brandMid.withOpacity(isDark ? 0.28 : 0.16),
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? (isDark ? Colors.white : AppColors.brandDeep)
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        space: 1,
      ),
    );
  }
}
