import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/habits_dao.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_stats.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/log_habit_progress.dart';
import '../../domain/usecases/toggle_habit_checklist_item.dart';
import '../../domain/usecases/update_habit.dart';

final Provider<HabitsDao> habitsDaoProvider = Provider<HabitsDao>((ref) {
  return HabitsDao(ref.watch(appDatabaseProvider));
});

final Provider<HabitRepository> habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(habitsDaoProvider));
});

final Provider<CreateHabit> createHabitUseCaseProvider = Provider(
  (ref) => CreateHabit(ref.watch(habitRepositoryProvider)),
);
final Provider<UpdateHabit> updateHabitUseCaseProvider = Provider(
  (ref) => UpdateHabit(ref.watch(habitRepositoryProvider)),
);
final Provider<DeleteHabit> deleteHabitUseCaseProvider = Provider(
  (ref) => DeleteHabit(ref.watch(habitRepositoryProvider)),
);
final Provider<LogHabitProgress> logHabitProgressUseCaseProvider = Provider(
  (ref) => LogHabitProgress(ref.watch(habitRepositoryProvider)),
);
final Provider<ToggleHabitChecklistItem> toggleHabitChecklistItemUseCaseProvider = Provider(
  (ref) => ToggleHabitChecklistItem(ref.watch(habitRepositoryProvider)),
);

final StreamProvider<List<Habit>> activeHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchActiveHabits();
});

final StreamProviderFamily<Habit?, String> habitByIdProvider =
    StreamProvider.family<Habit?, String>((ref, id) {
  return ref.watch(habitRepositoryProvider).watchHabit(id);
});

/// Every entry ever logged for a habit — the raw material for streak,
/// completion-rate and heatmap calculations (see `HabitStats`).
final StreamProviderFamily<List<HabitEntry>, String> entriesForHabitProvider =
    StreamProvider.family<List<HabitEntry>, String>((ref, habitId) {
  return ref.watch(habitRepositoryProvider).watchEntriesForHabit(habitId);
});

typedef HabitPeriodKey = ({String habitId, DateTime periodStart});

final StreamProviderFamily<HabitEntry?, HabitPeriodKey> entryForPeriodProvider =
    StreamProvider.family<HabitEntry?, HabitPeriodKey>((ref, key) {
  return ref.watch(habitRepositoryProvider).watchEntryForPeriod(key.habitId, key.periodStart);
});

/// Average this-week completion rate across every active habit — the
/// figure shown on the dashboard's "Habit completion" tile.
final Provider<AsyncValue<double>> habitsWeeklyCompletionProvider =
    Provider<AsyncValue<double>>((ref) {
  final AsyncValue<List<Habit>> habitsAsync = ref.watch(activeHabitsProvider);
  return habitsAsync.whenData((List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    final DateTime now = DateTime.now();
    final DateTime weekStart = HabitFrequency.weekly.periodStart(now);
    double total = 0;
    int counted = 0;

    for (final Habit habit in habits) {
      final List<HabitEntry>? entries =
          ref.watch(entriesForHabitProvider(habit.id)).valueOrNull;
      if (entries == null) continue;
      final Set<DateTime> completed = entries
          .where((e) => e.isCompleteFor(habit))
          .map((e) => e.periodStart)
          .toSet();
      total += HabitStats.completionRate(
        habit: habit,
        completedPeriods: completed,
        from: weekStart,
        to: now,
      );
      counted++;
    }
    return counted == 0 ? 0.0 : total / counted;
  });
});
