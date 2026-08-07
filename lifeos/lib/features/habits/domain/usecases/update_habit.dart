import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import 'create_habit.dart';

class UpdateHabit {
  UpdateHabit(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(Habit habit) async {
    final Failure? error = CreateHabit.validate(habit);
    if (error != null) return Result.err(error);
    return _repository.updateHabit(habit.copyWith(updatedAt: DateTime.now()));
  }
}
