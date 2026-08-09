import '../../../calendar/domain/entities/calendar_task.dart';
import '../../../creator_studio/domain/entities/content_project.dart';
import '../../../entertainment/domain/entities/media_item.dart';
import '../../../entertainment/domain/entities/media_status.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/domain/services/journal_stats.dart';
import '../entities/attribute.dart';
import '../entities/rank.dart';

/// Pure, DB-free aggregation that turns a live snapshot of every other
/// module's already-loaded data into the eight attributes, total XP,
/// current rank, Life Score and which achievements are currently
/// satisfied. Nothing here touches the database directly — the same
/// "compute over already-loaded lists" shape as every other module's
/// Stats service, just spanning all of them at once.
class GamificationStats {
  GamificationStats._();

  /// Net worth (in rupees) treated as "wealth points" — ₹1,00,000 maps
  /// to a full 100 score.
  static const double _wealthReferenceNetWorth = 100000;

  /// Workout sessions logged, scaled so 50 sessions is a full 100 score.
  static const double _vitalityPointsPerSession = 2;

  /// Published content pieces, scaled so 20 published is a full 100.
  static const double _creativityPointsPerPublished = 5;

  /// Completed media items, scaled so 25 completed is a full 100.
  static const double _culturePointsPerCompleted = 4;

  /// Journal streak days, scaled so a 20-day streak is a full 100.
  static const double _wisdomPointsPerStreakDay = 5;

  /// Every attribute point is worth 10 XP — 8 attributes at a max of
  /// 100 each yields a max of 8000 XP, matching [Rank.demonGod]'s
  /// threshold.
  static const double _xpPerAttributePoint = 10;

  static double _clampScore(double value) => value.clamp(0, 100).toDouble();

  static Map<Attribute, double> computeAttributes({
    required double netWorth,
    required int totalWorkoutSessions,
    required double habitWeeklyCompletionRate,
    required List<Goal> activeGoals,
    required List<ContentProject> contentProjects,
    required List<MediaItem> mediaItems,
    required List<JournalEntry> journalEntries,
    required List<CalendarTask> calendarTasks,
  }) {
    return {
      Attribute.wealth: _clampScore(netWorth / _wealthReferenceNetWorth * 100),
      Attribute.vitality: _clampScore(totalWorkoutSessions * _vitalityPointsPerSession),
      Attribute.discipline: _clampScore(habitWeeklyCompletionRate * 100),
      Attribute.willpower: _clampScore(_averageGoalProgress(activeGoals) * 100),
      Attribute.creativity: _clampScore(
        contentProjects.where((p) => p.isPublished).length * _creativityPointsPerPublished,
      ),
      Attribute.culture: _clampScore(
        mediaItems.where((m) => m.status == MediaStatus.completed).length * _culturePointsPerCompleted,
      ),
      Attribute.wisdom: _clampScore(
        JournalStats.currentStreak(journalEntries) * _wisdomPointsPerStreakDay,
      ),
      Attribute.order: _clampScore(_taskCompletionRate(calendarTasks) * 100),
    };
  }

  static double _averageGoalProgress(List<Goal> goals) {
    if (goals.isEmpty) return 0;
    final double total = goals.fold<double>(
      0,
      (sum, goal) => sum + (goal.targetValue <= 0 ? 0 : (goal.progressValue / goal.targetValue).clamp(0, 1)),
    );
    return total / goals.length;
  }

  static double _taskCompletionRate(List<CalendarTask> tasks) {
    if (tasks.isEmpty) return 0;
    return tasks.where((task) => task.isDone).length / tasks.length;
  }

  static int totalXp(Map<Attribute, double> attributes) {
    final double sum = attributes.values.fold<double>(0, (a, b) => a + b);
    return (sum * _xpPerAttributePoint).round();
  }

  /// The average of every attribute — "how balanced is your life right
  /// now," distinct from XP's cumulative "how far you've progressed."
  static double lifeScore(Map<Attribute, double> attributes) {
    if (attributes.isEmpty) return 0;
    final double sum = attributes.values.fold<double>(0, (a, b) => a + b);
    return sum / attributes.length;
  }

  static Rank rankForXp(int xp) {
    Rank current = Rank.values.first;
    for (final Rank rank in Rank.values) {
      if (xp >= rank.minXp) {
        current = rank;
      } else {
        break;
      }
    }
    return current;
  }

  /// Fraction (0-1) of the way from the current rank to the next one.
  /// 1.0 once the max rank is reached.
  static double progressToNextRank(int xp, Rank rank) {
    final Rank? next = rank.next;
    if (next == null) return 1;
    final int span = next.minXp - rank.minXp;
    if (span <= 0) return 1;
    return ((xp - rank.minXp) / span).clamp(0, 1).toDouble();
  }

  /// Which achievement keys are satisfied by the current snapshot. This
  /// is re-evaluated every time and only ever grows the persisted unlock
  /// set — see `UnlockAchievement`.
  static Set<String> evaluateAchievementKeys({
    required double netWorth,
    required int totalWorkoutSessions,
    required double habitWeeklyCompletionRate,
    required List<Goal> activeGoals,
    required List<ContentProject> contentProjects,
    required List<MediaItem> mediaItems,
    required List<JournalEntry> journalEntries,
    required List<CalendarTask> calendarTasks,
    required Rank rank,
    required Map<Attribute, double> attributes,
    required double lifeScore,
  }) {
    const double goalCrusherProgressThreshold = 0.5;
    const int goalCrusherCount = 5;
    const int goalCrusherIiCount = 15;

    final int meaningfulGoals = activeGoals
        .where(
          (goal) =>
              goal.targetValue > 0 &&
              (goal.progressValue / goal.targetValue) >= goalCrusherProgressThreshold,
        )
        .length;
    final int publishedCount = contentProjects.where((p) => p.isPublished).length;
    final int completedMediaCount = mediaItems.where((m) => m.status == MediaStatus.completed).length;
    final int journalStreak = JournalStats.currentStreak(journalEntries);
    final int doneTaskCount = calendarTasks.where((task) => task.isDone).length;

    return {
      // Milestones
      if (netWorth >= _wealthReferenceNetWorth) 'rich_cultivator',
      if (totalWorkoutSessions >= 10) 'iron_body',
      if (habitWeeklyCompletionRate >= 1.0) 'unbreakable',
      if (meaningfulGoals >= goalCrusherCount) 'goal_crusher',
      if (publishedCount >= 5) 'content_creator',
      if (completedMediaCount >= 10) 'completionist',
      if (journalStreak >= 14) 'deep_thinker',
      if (doneTaskCount >= 20) 'organized_mind',

      // Rank ascension — reaching a rank implies every lower rank was
      // already passed through, so these all unlock together.
      if (rank.index >= Rank.qiRefining.index) 'rank_qi_refining',
      if (rank.index >= Rank.foundationEstablishment.index) 'rank_foundation_establishment',
      if (rank.index >= Rank.coreFormation.index) 'rank_core_formation',
      if (rank.index >= Rank.nascentSoul.index) 'rank_nascent_soul',
      if (rank.index >= Rank.soulTransformation.index) 'rank_soul_transformation',
      if (rank.index >= Rank.voidTribulation.index) 'rank_void_tribulation',
      if (rank.index >= Rank.immortalAscension.index) 'rank_immortal_ascension',
      if (rank == Rank.demonGod) 'ascended',

      // Mastery — tier-2 module milestones and whole-life balance.
      if (totalWorkoutSessions >= 50) 'iron_body_ii',
      if (meaningfulGoals >= goalCrusherIiCount) 'goal_crusher_ii',
      if (publishedCount >= 15) 'content_creator_ii',
      if (completedMediaCount >= 25) 'completionist_ii',
      if (journalStreak >= 30) 'deep_thinker_ii',
      if (doneTaskCount >= 75) 'organized_mind_ii',
      if (attributes.values.every((value) => value >= 50)) 'renaissance',
      if (attributes.values.any((value) => value >= 100)) 'peak_of_a_path',
      if (lifeScore >= 90) 'true_sovereign',
    };
  }
}
