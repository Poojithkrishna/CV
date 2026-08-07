import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/habit_repository.dart';
import '../daos/habits_dao.dart';
import 'habit_entry_mapper.dart';
import 'habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._dao);

  final HabitsDao _dao;

  @override
  Stream<List<Habit>> watchActiveHabits() {
    return _dao
        .watchActiveHabits()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Habit?> watchHabit(String id) {
    return _dao.watchHabit(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    try {
      await _dao.insertHabit(habit.toCompanion());
      return Result.ok(habit);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save habit: $e'));
    }
  }

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    try {
      final bool updated = await _dao.updateHabit(habit.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Habit no longer exists.'));
      }
      return Result.ok(habit);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update habit: $e'));
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      await _dao.deleteHabit(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete habit: $e'));
    }
  }

  @override
  Stream<List<HabitEntry>> watchEntriesForHabit(String habitId) {
    return _dao
        .watchEntriesForHabit(habitId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<HabitEntry?> watchEntryForPeriod(String habitId, DateTime periodStart) {
    return _dao.watchEntryForPeriod(habitId, periodStart).map((row) => row?.toDomain());
  }

  @override
  Future<Result<void>> logProgress(String habitId, DateTime periodStart, double delta) async {
    try {
      await _dao.logProgress(habitId, periodStart, delta);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not log progress: $e'));
    }
  }

  @override
  Future<Result<void>> toggleChecklistItem(
    String habitId,
    DateTime periodStart,
    int itemIndex,
  ) async {
    try {
      await _dao.toggleChecklistItem(habitId, periodStart, itemIndex);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update checklist: $e'));
    }
  }
}
