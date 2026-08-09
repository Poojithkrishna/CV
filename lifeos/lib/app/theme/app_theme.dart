import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark Material 3 themes for Demon Origin.
///
/// The app is dark-mode-first (it's a personal, always-on-phone tool used
/// day and night) but a light theme is fully supported for daytime use.
class AppTheme {
  AppTheme._();

  /// The angular, sci-fi display face used only for brand moments (the
  /// "DEMON ORIGIN" wordmark, rank-up celebrations) — never for dense body
  /// or list text, where its wide letterforms hurt legibility. See
  /// `BrandWordmark`.
  static String get displayFontFamily => GoogleFonts.orbitron().fontFamily!;

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
      surface: isDark ? AppColors.darkSurface : const Color(0xFFFBFAFF),
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
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
        space: 1,
      ),
    );
  }
}
