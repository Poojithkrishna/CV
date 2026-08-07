import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';
import 'create_goal.dart';

class UpdateGoal {
  UpdateGoal(this._repository);

  final GoalRepository _repository;

  Future<Result<Goal>> call(Goal goal) async {
    final Failure? error = CreateGoal.validate(goal);
    if (error != null) return Result.err(error);
    return _repository.updateGoal(goal.copyWith(updatedAt: DateTime.now()));
  }
}
