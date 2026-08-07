import '../../../../core/utils/result.dart';
import '../repositories/workout_plan_repository.dart';

/// Switches which plan is active — instantly, per the spec ("allow
/// switching plans instantly"), so this is a single direct call rather
/// than a form.
class SetActivePlan {
  SetActivePlan(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<void>> call(String planId) => _repository.setActivePlan(planId);
}
