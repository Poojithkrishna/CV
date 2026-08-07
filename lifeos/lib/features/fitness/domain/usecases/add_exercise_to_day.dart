import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/plan_exercise.dart';
import '../repositories/workout_plan_repository.dart';

class AddExerciseToDay {
  AddExerciseToDay(this._repository);

  final WorkoutPlanRepository _repository;

  Future<Result<PlanExercise>> call(PlanExercise planExercise) async {
    final Failure? error = validate(planExercise);
    if (error != null) return Result.err(error);
    return _repository.addExerciseToDay(planExercise);
  }

  static Failure? validate(PlanExercise planExercise) {
    if (planExercise.targetSets <= 0) {
      return const ValidationFailure('Sets must be at least 1.');
    }
    if (planExercise.targetReps.trim().isEmpty) {
      return const ValidationFailure('Target reps are required.');
    }
    return null;
  }
}
