import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/workout_plan.dart';
import '../repositories/workout_plan_repository.dart';

class UpdateWorkoutPlan {
  UpdateWorkoutPlan(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<WorkoutPlan>> call(WorkoutPlan plan) async {
    if (plan.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Plan name is required.'));
    }
    return _repository.updatePlan(plan.copyWith(updatedAt: DateTime.now()));
  }
}
