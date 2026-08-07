import '../../../../core/utils/result.dart';
import '../repositories/workout_plan_repository.dart';

class RemoveExerciseFromDay {
  RemoveExerciseFromDay(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<void>> call(String id) => _repository.removeExerciseFromDay(id);
}
