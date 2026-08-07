import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabit {
  CreateHabit(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(Habit habit) async {
    final Failure? error = validate(habit);
    if (error != null) return Result.err(error);
    return _repository.createHabit(habit);
  }

  static Failure? validate(Habit habit) {
    if (habit.name.trim().isEmpty) {
      return const ValidationFailure('Habit name is required.');
    }
    if (habit.type.usesChecklistItems) {
      if (habit.checklistItems.where((item) => item.trim().isNotEmpty).isEmpty) {
        return const ValidationFailure('Add at least one checklist item.');
      }
    } else if (habit.targetValue <= 0) {
      return const ValidationFailure('Target must be greater than zero.');
    }
    return null;
  }
}
