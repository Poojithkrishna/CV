import 'package:flutter/material.dart';

/// A static achievement definition. The catalog never changes per-user
/// (much like the seeded default categories/exercises/foods), so it
/// lives entirely in code rather than a database table — only which
/// keys have been *unlocked* is persisted, via [UnlockedAchievement].
@immutable
class Achievement {
  const Achievement({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String key;
  final String title;
  final String description;
  final IconData icon;
}

/// Every achievement a cultivator can earn. Criteria are evaluated by
/// `GamificationStats.evaluateAchievementKeys` against live stats — once
/// a key is unlocked and persisted, it stays unlocked even if the
/// triggering stat later changes (e.g. net worth drops back down).
const List<Achievement> achievementCatalog = [
  Achievement(
    key: 'rich_cultivator',
    title: 'Rich Cultivator',
    description: 'Reach a net worth of ₹1,00,000.',
    icon: Icons.account_balance_wallet_rounded,
  ),
  Achievement(
    key: 'iron_body',
    title: 'Iron Body',
    description: 'Log 10 workout sessions.',
    icon: Icons.fitness_center_rounded,
  ),
  Achievement(
    key: 'unbreakable',
    title: 'Unbreakable',
    description: 'Complete every scheduled habit in a week.',
    icon: Icons.local_fire_department_rounded,
  ),
  Achievement(
    key: 'goal_crusher',
    title: 'Goal Crusher',
    description: 'Make meaningful progress on 5 goals.',
    icon: Icons.flag_rounded,
  ),
  Achievement(
    key: 'content_creator',
    title: 'Content Creator',
    description: 'Publish 5 pieces of content.',
    icon: Icons.videocam_rounded,
  ),
  Achievement(
    key: 'completionist',
    title: 'Completionist',
    description: 'Complete 10 games, movies, series or books.',
    icon: Icons.movie_filter_rounded,
  ),
  Achievement(
    key: 'deep_thinker',
    title: 'Deep Thinker',
    description: 'Reach a 14-day journaling streak.',
    icon: Icons.menu_book_rounded,
  ),
  Achievement(
    key: 'organized_mind',
    title: 'Organized Mind',
    description: 'Complete 20 tasks.',
    icon: Icons.calendar_month_rounded,
  ),
  Achievement(
    key: 'ascended',
    title: 'Ascended',
    description: 'Reach the Demon God rank.',
    icon: Icons.auto_awesome_rounded,
  ),
];
