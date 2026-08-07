import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/workout_day.dart';
import '../repositories/workout_plan_repository.dart';

class CreateWorkoutDay {
  CreateWorkoutDay(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<WorkoutDay>> call(WorkoutDay day) async {
    if (day.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Day name is required.'));
    }
    return _repository.createDay(day);
  }
}
