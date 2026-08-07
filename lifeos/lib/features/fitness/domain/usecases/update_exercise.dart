import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/exercise.dart';
import '../repositories/exercise_repository.dart';

class UpdateExercise {
  UpdateExercise(this._repository);

  final ExerciseRepository _repository;

  Future<Result<Exercise>> call(Exercise exercise) async {
    if (exercise.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Exercise name is required.'));
    }
    return _repository.updateExercise(exercise.copyWith(updatedAt: DateTime.now()));
  }
}
