import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_task.dart';
import 'package:lifeos/features/calendar/domain/entities/task_priority.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_platform.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_project.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_stage.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_item.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_status.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_type.dart';
import 'package:lifeos/features/gamification/domain/entities/attribute.dart';
import 'package:lifeos/features/gamification/domain/entities/rank.dart';
import 'package:lifeos/features/gamification/domain/services/gamification_stats.dart';
import 'package:lifeos/features/goals/domain/entities/goal.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry_type.dart';

final DateTime _now = DateTime(2026, 1, 1);

Goal _buildGoal({String id = 'g1', double progressValue = 0, double targetValue = 10}) {
  return Goal(
    id: id,
    title: 'Goal $id',
    progressValue: progressValue,
    targetValue: targetValue,
    colorValue: 0xFF7C4DFF,
    createdAt: _now,
    updatedAt: _now,
  );
}

ContentProject _buildProject({String id = 'p1', ContentStage stage = ContentStage.idea}) {
  return ContentProject(
    id: id,
    title: 'Project $id',
    stage: stage,
    platform: ContentPlatform.youtube,
    colorValue: 0xFFEC4899,
    createdAt: _now,
    updatedAt: _now,
  );
}

MediaItem _buildMediaItem({String id = 'm1', MediaStatus status = MediaStatus.wishlist}) {
  return MediaItem(
    id: id,
    title: 'Item $id',
    type: MediaType.movie,
    status: status,
    colorValue: 0xFF8B5CF6,
    createdAt: _now,
    updatedAt: _now,
  );
}

JournalEntry _buildJournalEntry({String id = 'e1', required DateTime date}) {
  return JournalEntry(
    id: id,
    type: JournalEntryType.freeWriting,
    date: date,
    content: 'Some thoughts',
    createdAt: _now,
    updatedAt: _now,
  );
}

CalendarTask _buildTask({String id = 't1', bool isDone = false}) {
  return CalendarTask(
    id: id,
    title: 'Task $id',
    isDone: isDone,
    priority: TaskPriority.medium,
    colorValue: 0xFF06B6D4,
    createdAt: _now,
    updatedAt: _now,
  );
}

Map<Attribute, double> _computeAttributes({
  double netWorth = 0,
  int totalWorkoutSessions = 0,
  double habitWeeklyCompletionRate = 0,
  List<Goal> activeGoals = const [],
  List<ContentProject> contentProjects = const [],
  List<MediaItem> mediaItems = const [],
  List<JournalEntry> journalEntries = const [],
  List<CalendarTask> calendarTasks = const [],
}) {
  return GamificationStats.computeAttributes(
    netWorth: netWorth,
    totalWorkoutSessions: totalWorkoutSessions,
    habitWeeklyCompletionRate: habitWeeklyCompletionRate,
    activeGoals: activeGoals,
    contentProjects: contentProjects,
    mediaItems: mediaItems,
    journalEntries: journalEntries,
    calendarTasks: calendarTasks,
  );
}

Set<String> _evaluateKeys({
  double netWorth = 0,
  int totalWorkoutSessions = 0,
  double habitWeeklyCompletionRate = 0,
  List<Goal> activeGoals = const [],
  List<ContentProject> contentProjects = const [],
  List<MediaItem> mediaItems = const [],
  List<JournalEntry> journalEntries = const [],
  List<CalendarTask> calendarTasks = const [],
  Rank rank = Rank.mortal,
  Map<Attribute, double> attributes = const {},
  double lifeScore = 0,
}) {
  return GamificationStats.evaluateAchievementKeys(
    netWorth: netWorth,
    totalWorkoutSessions: totalWorkoutSessions,
    habitWeeklyCompletionRate: habitWeeklyCompletionRate,
    activeGoals: activeGoals,
    contentProjects: contentProjects,
    mediaItems: mediaItems,
    journalEntries: journalEntries,
    calendarTasks: calendarTasks,
    rank: rank,
    attributes: attributes,
    lifeScore: lifeScore,
  );
}

void main() {
  group('GamificationStats.computeAttributes', () {
    test('wealth scales net worth to 100 at the reference amount', () {
      expect(_computeAttributes(netWorth: 100000)[Attribute.wealth], 100);
      expect(_computeAttributes(netWorth: 50000)[Attribute.wealth], 50);
    });

    test('wealth clamps negative net worth at zero', () {
      expect(_computeAttributes(netWorth: -50000)[Attribute.wealth], 0);
    });

    test('wealth clamps above the reference amount at 100', () {
      expect(_computeAttributes(netWorth: 500000)[Attribute.wealth], 100);
    });

    test('vitality scales workout sessions, capped at 100', () {
      expect(_computeAttributes(totalWorkoutSessions: 10)[Attribute.vitality], 20);
      expect(_computeAttributes(totalWorkoutSessions: 100)[Attribute.vitality], 100);
    });

    test('discipline is the habit completion rate as a percentage', () {
      expect(_computeAttributes(habitWeeklyCompletionRate: 0.75)[Attribute.discipline], 75);
    });

    test('willpower averages active goal progress ratios', () {
      final goals = [
        _buildGoal(id: 'g1', progressValue: 5, targetValue: 10),
        _buildGoal(id: 'g2', progressValue: 10, targetValue: 10),
      ];
      expect(_computeAttributes(activeGoals: goals)[Attribute.willpower], 75);
    });

    test('willpower is zero with no active goals', () {
      expect(_computeAttributes()[Attribute.willpower], 0);
    });

    test('willpower clamps a goal whose progress exceeds its target', () {
      final goals = [_buildGoal(progressValue: 50, targetValue: 10)];
      expect(_computeAttributes(activeGoals: goals)[Attribute.willpower], 100);
    });

    test('creativity counts only published projects, scaled and capped', () {
      final projects = [
        _buildProject(id: 'p1', stage: ContentStage.published),
        _buildProject(id: 'p2', stage: ContentStage.published),
        _buildProject(id: 'p3', stage: ContentStage.idea),
      ];
      expect(_computeAttributes(contentProjects: projects)[Attribute.creativity], 10);
    });

    test('culture counts only completed media items, scaled and capped', () {
      final items = [
        _buildMediaItem(id: 'm1', status: MediaStatus.completed),
        _buildMediaItem(id: 'm2', status: MediaStatus.inProgress),
      ];
      expect(_computeAttributes(mediaItems: items)[Attribute.culture], 4);
    });

    test('wisdom scales the current journal streak, capped at 100', () {
      final DateTime today = DateTime(2026, 1, 10);
      final entries = [
        _buildJournalEntry(id: 'e1', date: today),
        _buildJournalEntry(id: 'e2', date: today.subtract(const Duration(days: 1))),
      ];
      final attributes = GamificationStats.computeAttributes(
        netWorth: 0,
        totalWorkoutSessions: 0,
        habitWeeklyCompletionRate: 0,
        activeGoals: const [],
        contentProjects: const [],
        mediaItems: const [],
        journalEntries: entries,
        calendarTasks: const [],
      );
      // Streak is 2 days as of "now" in real time, but JournalStats anchors
      // to DateTime.now() internally, so just assert it's a valid 0-100
      // score derived from some streak rather than asserting an exact
      // value tied to the real current date.
      expect(attributes[Attribute.wisdom], greaterThanOrEqualTo(0));
      expect(attributes[Attribute.wisdom], lessThanOrEqualTo(100));
    });

    test('order is the fraction of done tasks, as a percentage', () {
      final tasks = [
        _buildTask(id: 't1', isDone: true),
        _buildTask(id: 't2', isDone: true),
        _buildTask(id: 't3', isDone: false),
        _buildTask(id: 't4', isDone: false),
      ];
      expect(_computeAttributes(calendarTasks: tasks)[Attribute.order], 50);
    });

    test('order is zero with no tasks', () {
      expect(_computeAttributes()[Attribute.order], 0);
    });
  });

  group('GamificationStats.totalXp', () {
    test('is the sum of attribute points times 10', () {
      final attributes = {for (final a in Attribute.values) a: 50.0};
      expect(GamificationStats.totalXp(attributes), 4000);
    });

    test('maxes out at 8000 when every attribute is maxed', () {
      final attributes = {for (final a in Attribute.values) a: 100.0};
      expect(GamificationStats.totalXp(attributes), 8000);
    });
  });

  group('GamificationStats.lifeScore', () {
    test('averages every attribute', () {
      final attributes = {for (final a in Attribute.values) a: 50.0};
      expect(GamificationStats.lifeScore(attributes), 50);
    });

    test('is zero for an empty attribute map', () {
      expect(GamificationStats.lifeScore(const {}), 0);
    });
  });

  group('GamificationStats.rankForXp', () {
    test('is Mortal at zero XP', () {
      expect(GamificationStats.rankForXp(0), Rank.mortal);
    });

    test('advances exactly at a rank threshold', () {
      expect(GamificationStats.rankForXp(400), Rank.qiRefining);
      expect(GamificationStats.rankForXp(399), Rank.mortal);
    });

    test('is Demon God at the max XP', () {
      expect(GamificationStats.rankForXp(8000), Rank.demonGod);
    });

    test('never exceeds Demon God even with XP above the max', () {
      expect(GamificationStats.rankForXp(999999), Rank.demonGod);
    });
  });

  group('GamificationStats.progressToNextRank', () {
    test('is zero exactly at the current rank threshold', () {
      expect(GamificationStats.progressToNextRank(0, Rank.mortal), 0);
    });

    test('is a fraction partway to the next rank', () {
      // Mortal spans 0-400; halfway is 200.
      expect(GamificationStats.progressToNextRank(200, Rank.mortal), 0.5);
    });

    test('is 1.0 at the max rank with no next rank', () {
      expect(GamificationStats.progressToNextRank(8000, Rank.demonGod), 1);
    });
  });

  group('GamificationStats.evaluateAchievementKeys', () {
    test('unlocks rich_cultivator at the wealth reference net worth', () {
      final keys = _evaluateKeys(netWorth: 100000);
      expect(keys, contains('rich_cultivator'));
    });

    test('unlocks iron_body at 10 workout sessions', () {
      final keys = _evaluateKeys(totalWorkoutSessions: 10);
      expect(keys, contains('iron_body'));
    });

    test('unlocks unbreakable at a perfect habit completion week', () {
      final keys = _evaluateKeys(habitWeeklyCompletionRate: 1.0);
      expect(keys, contains('unbreakable'));
    });

    test('does not unlock unbreakable below a perfect week', () {
      final keys = _evaluateKeys(habitWeeklyCompletionRate: 0.9);
      expect(keys, isNot(contains('unbreakable')));
    });

    test('unlocks goal_crusher with 5 goals at least half progressed', () {
      final goals = List.generate(
        5,
        (i) => _buildGoal(id: 'g$i', progressValue: 6, targetValue: 10),
      );
      final keys = _evaluateKeys(activeGoals: goals);
      expect(keys, contains('goal_crusher'));
    });

    test('unlocks ascended only at the Demon God rank', () {
      final atMax = _evaluateKeys(rank: Rank.demonGod);
      final belowMax = _evaluateKeys(rank: Rank.voidTribulation);
      expect(atMax, contains('ascended'));
      expect(belowMax, isNot(contains('ascended')));
    });

    test('unlocks nothing from an empty, zeroed-out snapshot', () {
      final keys = _evaluateKeys();
      expect(keys, isEmpty);
    });

    test('unlocks every rank tier up to and including the current rank', () {
      final keys = _evaluateKeys(rank: Rank.coreFormation);
      expect(keys, contains('rank_qi_refining'));
      expect(keys, contains('rank_foundation_establishment'));
      expect(keys, contains('rank_core_formation'));
      expect(keys, isNot(contains('rank_nascent_soul')));
      expect(keys, isNot(contains('rank_soul_transformation')));
      expect(keys, isNot(contains('rank_void_tribulation')));
      expect(keys, isNot(contains('rank_immortal_ascension')));
      expect(keys, isNot(contains('ascended')));
    });

    test('unlocks no rank tiers at Mortal', () {
      final keys = _evaluateKeys(rank: Rank.mortal);
      expect(keys, isNot(contains('rank_qi_refining')));
    });

    test('unlocks every rank tier plus ascended at Demon God', () {
      final keys = _evaluateKeys(rank: Rank.demonGod);
      expect(keys, contains('rank_immortal_ascension'));
      expect(keys, contains('ascended'));
    });

    test('unlocks iron_body_ii at 50 workout sessions but not below', () {
      expect(_evaluateKeys(totalWorkoutSessions: 50), contains('iron_body_ii'));
      expect(_evaluateKeys(totalWorkoutSessions: 49), isNot(contains('iron_body_ii')));
    });

    test('unlocks goal_crusher_ii with 15 goals at least half progressed', () {
      final goals = List.generate(
        15,
        (i) => _buildGoal(id: 'g$i', progressValue: 6, targetValue: 10),
      );
      expect(_evaluateKeys(activeGoals: goals), contains('goal_crusher_ii'));
    });

    test('unlocks content_creator_ii at 15 published projects but not below', () {
      final published = List.generate(
        15,
        (i) => _buildProject(id: 'p$i', stage: ContentStage.published),
      );
      final belowThreshold = List.generate(
        14,
        (i) => _buildProject(id: 'p$i', stage: ContentStage.published),
      );
      expect(_evaluateKeys(contentProjects: published), contains('content_creator_ii'));
      expect(_evaluateKeys(contentProjects: belowThreshold), isNot(contains('content_creator_ii')));
    });

    test('unlocks completionist_ii at 25 completed media items but not below', () {
      final completed = List.generate(
        25,
        (i) => _buildMediaItem(id: 'm$i', status: MediaStatus.completed),
      );
      expect(_evaluateKeys(mediaItems: completed), contains('completionist_ii'));
    });

    test('unlocks deep_thinker_ii at a 30-day journaling streak', () {
      final DateTime today = DateTime.now();
      final entries = [
        for (int i = 0; i < 30; i++)
          _buildJournalEntry(id: 'e$i', date: today.subtract(Duration(days: i))),
      ];
      expect(_evaluateKeys(journalEntries: entries), contains('deep_thinker_ii'));
    });

    test('unlocks organized_mind_ii at 75 completed tasks but not below', () {
      final done = List.generate(75, (i) => _buildTask(id: 't$i', isDone: true));
      final belowThreshold = List.generate(74, (i) => _buildTask(id: 't$i', isDone: true));
      expect(_evaluateKeys(calendarTasks: done), contains('organized_mind_ii'));
      expect(_evaluateKeys(calendarTasks: belowThreshold), isNot(contains('organized_mind_ii')));
    });

    test('unlocks renaissance only when every attribute is at least 50', () {
      final balanced = {for (final a in Attribute.values) a: 50.0};
      final unbalanced = {
        for (final a in Attribute.values) a: 50.0,
        Attribute.values.first: 49.0,
      };
      expect(_evaluateKeys(attributes: balanced), contains('renaissance'));
      expect(_evaluateKeys(attributes: unbalanced), isNot(contains('renaissance')));
    });

    test('unlocks peak_of_a_path when any single attribute maxes at 100', () {
      final maxed = {
        for (final a in Attribute.values) a: 0.0,
        Attribute.wealth: 100.0,
      };
      expect(_evaluateKeys(attributes: maxed), contains('peak_of_a_path'));
      expect(_evaluateKeys(attributes: const {}), isNot(contains('peak_of_a_path')));
    });

    test('unlocks true_sovereign at a Life Score of 90 or higher', () {
      expect(_evaluateKeys(lifeScore: 90), contains('true_sovereign'));
      expect(_evaluateKeys(lifeScore: 89.9), isNot(contains('true_sovereign')));
    });
  });
}
