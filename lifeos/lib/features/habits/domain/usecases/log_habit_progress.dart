import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Logs progress for whatever period [asOf] falls into — the repository
/// upserts, so callers don't need to know if this is the first log of the
/// period or an addition to an existing one. [delta] may be negative to
/// undo a tap; the stored value never drops below zero.
class LogHabitProgress {
  LogHabitProgress(this._repository);

  final HabitRepository _repository;

  Future<Result<void>> call(Habit habit, double delta, {DateTime? asOf}) {
    final DateTime periodStart = habit.frequency.periodStart(asOf ?? DateTime.now());
    return _repository.logProgress(habit.id, periodStart, delta);
  }
}
