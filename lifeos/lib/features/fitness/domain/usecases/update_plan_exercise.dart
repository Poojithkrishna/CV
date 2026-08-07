import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/plan_exercise.dart';
import '../repositories/workout_plan_repository.dart';
import 'add_exercise_to_day.dart';

class UpdatePlanExercise {
  UpdatePlanExercise(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<PlanExercise>> call(PlanExercise planExercise) async {
    final Failure? error = AddExerciseToDay.validate(planExercise);
    if (error != null) return Result.err(error);
    return _repository.updatePlanExercise(planExercise.copyWith(updatedAt: DateTime.now()));
  }
}
