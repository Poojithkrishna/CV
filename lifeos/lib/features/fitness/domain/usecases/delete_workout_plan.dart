import '../../../../core/utils/result.dart';
import '../repositories/workout_plan_repository.dart';

class DeleteWorkoutPlan {
  DeleteWorkoutPlan(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<void>> call(String id) => _repository.deletePlan(id);
}
