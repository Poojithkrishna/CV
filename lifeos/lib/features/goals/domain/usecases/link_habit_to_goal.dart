import '../../../../core/utils/result.dart';
import '../repositories/goal_repository.dart';

class LinkHabitToGoal {
  LinkHabitToGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<void>> call(String goalId, String habitId) =>
      _repository.linkHabit(goalId, habitId);
}
