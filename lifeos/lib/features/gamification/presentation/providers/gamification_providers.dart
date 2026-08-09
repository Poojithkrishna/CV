import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../calendar/domain/entities/calendar_task.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../../creator_studio/domain/entities/content_project.dart';
import '../../../creator_studio/presentation/providers/content_studio_providers.dart';
import '../../../entertainment/domain/entities/media_item.dart';
import '../../../entertainment/presentation/providers/media_library_providers.dart';
import '../../../finance/domain/repositories/account_repository.dart';
import '../../../finance/presentation/providers/net_worth_provider.dart';
import '../../../fitness/presentation/providers/workout_session_providers.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../journal/domain/entities/journal_entry.dart';
import '../../../journal/presentation/providers/journal_providers.dart';
import '../../data/daos/gamification_dao.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../domain/entities/gamification_snapshot.dart';
import '../../domain/entities/unlocked_achievement.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/services/gamification_stats.dart';
import '../../domain/usecases/unlock_achievement.dart';

final Provider<GamificationDao> gamificationDaoProvider = Provider<GamificationDao>((ref) {
  return GamificationDao(ref.watch(appDatabaseProvider));
});

final Provider<GamificationRepository> gamificationRepositoryProvider =
    Provider<GamificationRepository>((ref) {
  return GamificationRepositoryImpl(ref.watch(gamificationDaoProvider));
});

final Provider<UnlockAchievement> unlockAchievementUseCaseProvider = Provider(
  (ref) => UnlockAchievement(ref.watch(gamificationRepositoryProvider)),
);

final StreamProvider<List<UnlockedAchievement>> unlockedAchievementsProvider =
    StreamProvider<List<UnlockedAchievement>>((ref) {
  return ref.watch(gamificationRepositoryProvider).watchUnlockedAchievements();
});

/// Combines every other module's live data into one computed
/// [GamificationSnapshot] — the same "watch every source, wait for all
/// of them, then compute" shape as `netWorthSummaryProvider`, just
/// spanning eight modules instead of five.
final Provider<AsyncValue<GamificationSnapshot>> gamificationSnapshotProvider =
    Provider<AsyncValue<GamificationSnapshot>>((ref) {
  final AsyncValue<NetWorthSummary> netWorthAsync = ref.watch(netWorthSummaryProvider);
  final AsyncValue<int> sessionCountAsync = ref.watch(workoutSessionCountProvider);
  final AsyncValue<double> habitCompletionAsync = ref.watch(habitsWeeklyCompletionProvider);
  final AsyncValue<List<Goal>> goalsAsync = ref.watch(activeGoalsProvider);
  final AsyncValue<List<ContentProject>> contentProjectsAsync = ref.watch(allContentProjectsProvider);
  final AsyncValue<List<MediaItem>> mediaItemsAsync = ref.watch(allMediaItemsProvider);
  final AsyncValue<List<JournalEntry>> journalEntriesAsync = ref.watch(allJournalEntriesProvider);
  final AsyncValue<List<CalendarTask>> calendarTasksAsync = ref.watch(allTasksProvider);

  final NetWorthSummary? netWorthSummary = netWorthAsync.valueOrNull;
  final int? sessionCount = sessionCountAsync.valueOrNull;
  final double? habitCompletion = habitCompletionAsync.valueOrNull;
  final List<Goal>? goals = goalsAsync.valueOrNull;
  final List<ContentProject>? contentProjects = contentProjectsAsync.valueOrNull;
  final List<MediaItem>? mediaItems = mediaItemsAsync.valueOrNull;
  final List<JournalEntry>? journalEntries = journalEntriesAsync.valueOrNull;
  final List<CalendarTask>? calendarTasks = calendarTasksAsync.valueOrNull;

  if (netWorthSummary == null ||
      sessionCount == null ||
      habitCompletion == null ||
      goals == null ||
      contentProjects == null ||
      mediaItems == null ||
      journalEntries == null ||
      calendarTasks == null) {
    for (final AsyncValue<Object?> source in [
      netWorthAsync,
      sessionCountAsync,
      habitCompletionAsync,
      goalsAsync,
      contentProjectsAsync,
      mediaItemsAsync,
      journalEntriesAsync,
      calendarTasksAsync,
    ]) {
      if (source.hasError) {
        return AsyncValue.error(source.error!, source.stackTrace ?? StackTrace.current);
      }
    }
    return const AsyncValue.loading();
  }

  final attributes = GamificationStats.computeAttributes(
    netWorth: netWorthSummary.netWorth,
    totalWorkoutSessions: sessionCount,
    habitWeeklyCompletionRate: habitCompletion,
    activeGoals: goals,
    contentProjects: contentProjects,
    mediaItems: mediaItems,
    journalEntries: journalEntries,
    calendarTasks: calendarTasks,
  );
  final int xp = GamificationStats.totalXp(attributes);
  final rank = GamificationStats.rankForXp(xp);

  return AsyncValue.data(
    GamificationSnapshot(
      attributes: attributes,
      xp: xp,
      rank: rank,
      progressToNextRank: GamificationStats.progressToNextRank(xp, rank),
      lifeScore: GamificationStats.lifeScore(attributes),
      satisfiedAchievementKeys: GamificationStats.evaluateAchievementKeys(
        netWorth: netWorthSummary.netWorth,
        totalWorkoutSessions: sessionCount,
        habitWeeklyCompletionRate: habitCompletion,
        activeGoals: goals,
        contentProjects: contentProjects,
        mediaItems: mediaItems,
        journalEntries: journalEntries,
        calendarTasks: calendarTasks,
        rank: rank,
      ),
    ),
  );
});
