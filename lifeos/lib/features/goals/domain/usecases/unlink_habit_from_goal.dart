import '../../../../core/utils/result.dart';
import '../repositories/goal_repository.dart';

class UnlinkHabitFromGoal {
  UnlinkHabitFromGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<void>> call(String goalId, String habitId) =>
      _repository.unlinkHabit(goalId, habitId);
}
