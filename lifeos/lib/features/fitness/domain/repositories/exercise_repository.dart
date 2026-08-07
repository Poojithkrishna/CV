import '../../../../core/utils/result.dart';
import '../entities/exercise.dart';
import '../entities/muscle_group.dart';

abstract interface class ExerciseRepository {
  Stream<List<Exercise>> watchExercises({MuscleGroup? muscleGroup});
  Stream<Exercise?> watchExercise(String id);

  Future<Result<Exercise>> createExercise(Exercise exercise);
  Future<Result<Exercise>> updateExercise(Exercise exercise);
  Future<Result<void>> deleteExercise(String id);
}
