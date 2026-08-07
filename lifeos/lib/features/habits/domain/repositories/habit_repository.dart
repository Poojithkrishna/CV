import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../entities/habit_entry.dart';

abstract interface class HabitRepository {
  Stream<List<Habit>> watchActiveHabits();
  Stream<Habit?> watchHabit(String id);

  Future<Result<Habit>> createHabit(Habit habit);
  Future<Result<Habit>> updateHabit(Habit habit);
  Future<Result<void>> deleteHabit(String id);

  Stream<List<HabitEntry>> watchEntriesForHabit(String habitId);
  Stream<HabitEntry?> watchEntryForPeriod(String habitId, DateTime periodStart);

  Future<Result<void>> logProgress(String habitId, DateTime periodStart, double delta);
  Future<Result<void>> toggleChecklistItem(String habitId, DateTime periodStart, int itemIndex);
}
