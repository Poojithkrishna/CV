import 'package:flutter/material.dart';

/// The eight attributes, each derived purely from one other module's
/// already-loaded data — see `GamificationStats.computeAttributes`.
enum Attribute {
  wealth('Wealth', Icons.account_balance_wallet_rounded, Color(0xFF22C55E)),
  vitality('Vitality', Icons.fitness_center_rounded, Color(0xFFEF4444)),
  discipline('Discipline', Icons.local_fire_department_rounded, Color(0xFFF59E0B)),
  willpower('Willpower', Icons.flag_rounded, Color(0xFF3B82F6)),
  creativity('Creativity', Icons.videocam_rounded, Color(0xFFEC4899)),
  culture('Culture', Icons.movie_filter_rounded, Color(0xFF8B5CF6)),
  wisdom('Wisdom', Icons.menu_book_rounded, Color(0xFF14B8A6)),
  order('Order', Icons.calendar_month_rounded, Color(0xFF06B6D4));

  const Attribute(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
