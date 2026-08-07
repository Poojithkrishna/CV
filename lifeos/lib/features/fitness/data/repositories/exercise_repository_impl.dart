import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_group.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../daos/exercises_dao.dart';
import 'exercise_mapper.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._dao);

  final ExercisesDao _dao;

  @override
  Stream<List<Exercise>> watchExercises({MuscleGroup? muscleGroup}) {
    return _dao
        .watchActiveExercises(muscleGroup: muscleGroup?.name)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Exercise?> watchExercise(String id) {
    return _dao.watchExercise(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Exercise>> createExercise(Exercise exercise) async {
    try {
      await _dao.insertExercise(exercise.toCompanion());
      return Result.ok(exercise);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save exercise: $e'));
    }
  }

  @override
  Future<Result<Exercise>> updateExercise(Exercise exercise) async {
    try {
      final bool updated = await _dao.updateExercise(exercise.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Exercise no longer exists.'));
      }
      return Result.ok(exercise);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update exercise: $e'));
    }
  }

  @override
  Future<Result<void>> deleteExercise(String id) async {
    try {
      await _dao.deleteExercise(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete exercise: $e'));
    }
  }
}
