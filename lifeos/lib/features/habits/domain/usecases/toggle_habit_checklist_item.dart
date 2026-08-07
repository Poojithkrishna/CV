import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class ToggleHabitChecklistItem {
  ToggleHabitChecklistItem(this._repository);

  final HabitRepository _repository;

  Future<Result<void>> call(Habit habit, int itemIndex, {DateTime? asOf}) {
    if (itemIndex < 0 || itemIndex >= habit.checklistItems.length) {
      return Future.value(
        const Result.err(ValidationFailure('That checklist item no longer exists.')),
      );
    }
    final DateTime periodStart = habit.frequency.periodStart(asOf ?? DateTime.now());
    return _repository.toggleChecklistItem(habit.id, periodStart, itemIndex);
  }
}
