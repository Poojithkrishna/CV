import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class CreateGoal {
  CreateGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<Goal>> call(Goal goal) async {
    final Failure? error = validate(goal);
    if (error != null) return Result.err(error);
    return _repository.createGoal(goal);
  }

  static Failure? validate(Goal goal) {
    if (goal.title.trim().isEmpty) {
      return const ValidationFailure('Goal title is required.');
    }
    if (goal.targetValue <= 0) {
      return const ValidationFailure('Target must be greater than zero.');
    }
    return null;
  }
}
