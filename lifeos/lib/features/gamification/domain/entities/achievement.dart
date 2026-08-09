import 'package:flutter/material.dart';

import 'rank.dart';

/// Groups the achievement grid into sections so the growing catalog
/// stays scannable instead of one long undifferentiated wall of cards.
enum AchievementCategory {
  milestones('Milestones'),
  ranks('Rank Ascension'),
  mastery('Mastery');

  const AchievementCategory(this.label);

  final String label;
}

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
    required this.category,
  });

  final String key;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
}

/// Every achievement a cultivator can earn. Criteria are evaluated by
/// `GamificationStats.evaluateAchievementKeys` against live stats — once
/// a key is unlocked and persisted, it stays unlocked even if the
/// triggering stat later changes (e.g. net worth drops back down).
const List<Achievement> achievementCatalog = [
  // --- Milestones: the first taste of each module's core loop. ---
  Achievement(
    key: 'rich_cultivator',
    title: 'Rich Cultivator',
    description: 'Reach a net worth of ₹1,00,000.',
    icon: Icons.account_balance_wallet_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'iron_body',
    title: 'Iron Body',
    description: 'Log 10 workout sessions.',
    icon: Icons.fitness_center_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'unbreakable',
    title: 'Unbreakable',
    description: 'Complete every scheduled habit in a week.',
    icon: Icons.local_fire_department_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'goal_crusher',
    title: 'Goal Crusher',
    description: 'Make meaningful progress on 5 goals.',
    icon: Icons.flag_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'content_creator',
    title: 'Content Creator',
    description: 'Publish 5 pieces of content.',
    icon: Icons.videocam_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'completionist',
    title: 'Completionist',
    description: 'Complete 10 games, movies, series or books.',
    icon: Icons.movie_filter_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'deep_thinker',
    title: 'Deep Thinker',
    description: 'Reach a 14-day journaling streak.',
    icon: Icons.menu_book_rounded,
    category: AchievementCategory.milestones,
  ),
  Achievement(
    key: 'organized_mind',
    title: 'Organized Mind',
    description: 'Complete 20 tasks.',
    icon: Icons.calendar_month_rounded,
    category: AchievementCategory.milestones,
  ),

  // --- Rank Ascension: one per rung of the cultivation ladder. ---
  Achievement(
    key: 'rank_qi_refining',
    title: Rank.qiRefining.label,
    description: 'Reach the Qi Refining rank — ${Rank.qiRefining.flavorTitle}.',
    icon: Rank.qiRefining.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_foundation_establishment',
    title: Rank.foundationEstablishment.label,
    description:
        'Reach the Foundation Establishment rank — ${Rank.foundationEstablishment.flavorTitle}.',
    icon: Rank.foundationEstablishment.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_core_formation',
    title: Rank.coreFormation.label,
    description: 'Reach the Core Formation rank — ${Rank.coreFormation.flavorTitle}.',
    icon: Rank.coreFormation.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_nascent_soul',
    title: Rank.nascentSoul.label,
    description: 'Reach the Nascent Soul rank — ${Rank.nascentSoul.flavorTitle}.',
    icon: Rank.nascentSoul.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_soul_transformation',
    title: Rank.soulTransformation.label,
    description: 'Reach the Soul Transformation rank — ${Rank.soulTransformation.flavorTitle}.',
    icon: Rank.soulTransformation.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_void_tribulation',
    title: Rank.voidTribulation.label,
    description: 'Reach the Void Tribulation rank — ${Rank.voidTribulation.flavorTitle}.',
    icon: Rank.voidTribulation.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'rank_immortal_ascension',
    title: Rank.immortalAscension.label,
    description: 'Reach the Immortal Ascension rank — ${Rank.immortalAscension.flavorTitle}.',
    icon: Rank.immortalAscension.icon,
    category: AchievementCategory.ranks,
  ),
  Achievement(
    key: 'ascended',
    title: 'Ascended',
    description: 'Reach the Demon God rank.',
    icon: Icons.auto_awesome_rounded,
    category: AchievementCategory.ranks,
  ),

  // --- Mastery: tier-2 module milestones, plus whole-life balance. ---
  Achievement(
    key: 'iron_body_ii',
    title: 'Iron Body II',
    description: 'Log 50 workout sessions.',
    icon: Icons.sports_gymnastics_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'goal_crusher_ii',
    title: 'Goal Crusher II',
    description: 'Make meaningful progress on 15 goals.',
    icon: Icons.military_tech_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'content_creator_ii',
    title: 'Content Creator II',
    description: 'Publish 15 pieces of content.',
    icon: Icons.podcasts_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'completionist_ii',
    title: 'Completionist II',
    description: 'Complete 25 games, movies, series or books.',
    icon: Icons.theaters_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'deep_thinker_ii',
    title: 'Deep Thinker II',
    description: 'Reach a 30-day journaling streak.',
    icon: Icons.auto_stories_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'organized_mind_ii',
    title: 'Organized Mind II',
    description: 'Complete 75 tasks.',
    icon: Icons.fact_check_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'renaissance',
    title: 'Renaissance',
    description: 'Bring every attribute to at least 50.',
    icon: Icons.hub_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'peak_of_a_path',
    title: 'Peak of a Path',
    description: 'Max out any single attribute at 100.',
    icon: Icons.landscape_rounded,
    category: AchievementCategory.mastery,
  ),
  Achievement(
    key: 'true_sovereign',
    title: 'True Sovereign',
    description: 'Reach a Life Score of 90 or higher.',
    icon: Icons.workspace_premium_rounded,
    category: AchievementCategory.mastery,
  ),
];
