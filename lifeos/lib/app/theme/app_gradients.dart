import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable gradients for the "premium glassmorphism" look used across
/// dashboard tiles, account cards and module headers.
class AppGradients {
  AppGradients._();

  /// The signature Demon Origin brand gradient — crimson bleeding into
  /// violet, matching the app icon and splash. Used for the brand wordmark,
  /// the dashboard hero glow and anything meant to feel like "the app"
  /// rather than a specific module.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brandCrimson, AppColors.brandViolet],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9333EA), Color(0xFF4C1D95)],
  );

  static const LinearGradient finance = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF0F7A3D)],
  );

  static const LinearGradient fitness = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
  );

  static const LinearGradient habits = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
  );

  static const LinearGradient goals = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );

  static const LinearGradient gamification = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDC2626), Color(0xFF450A0A)],
  );

  /// Glassmorphism overlay used on top of background art/images.
  static LinearGradient glass(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]
          : [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.25)],
    );
  }

  /// A soft ambient-glow shadow in [color], for emphasis surfaces (hero
  /// cards, the selected nav icon, primary buttons) that should look like
  /// they're lit from behind rather than merely elevated.
  static List<BoxShadow> glowShadow(Color color, {double intensity = 1}) => [
        BoxShadow(
          color: color.withOpacity(0.35 * intensity),
          blurRadius: 24 * intensity,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: color.withOpacity(0.18 * intensity),
          blurRadius: 48 * intensity,
          spreadRadius: 4,
        ),
      ];

  /// Returns a fixed set of gradients users can pick from when customizing
  /// an account / habit / project color theme.
  static const List<LinearGradient> palette = [
    primary,
    finance,
    fitness,
    habits,
    goals,
    gamification,
    LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0E7490)]),
    LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF9D174D)]),
    LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF5B21B6)]),
    LinearGradient(colors: [Color(0xFF64748B), Color(0xFF1E293B)]),
  ];
}
