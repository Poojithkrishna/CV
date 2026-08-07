import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/exercises_dao.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_group.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/usecases/create_exercise.dart';
import '../../domain/usecases/delete_exercise.dart';
import '../../domain/usecases/update_exercise.dart';

final Provider<ExercisesDao> exercisesDaoProvider = Provider<ExercisesDao>((ref) {
  return ExercisesDao(ref.watch(appDatabaseProvider));
});

final Provider<ExerciseRepository> exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(exercisesDaoProvider));
});

final Provider<CreateExercise> createExerciseUseCaseProvider = Provider(
  (ref) => CreateExercise(ref.watch(exerciseRepositoryProvider)),
);

final Provider<UpdateExercise> updateExerciseUseCaseProvider = Provider(
  (ref) => UpdateExercise(ref.watch(exerciseRepositoryProvider)),
);

final Provider<DeleteExercise> deleteExerciseUseCaseProvider = Provider(
  (ref) => DeleteExercise(ref.watch(exerciseRepositoryProvider)),
);

/// All exercises, unfiltered — used by pickers (e.g. adding an exercise
/// to a plan day) where the muscle-group filter chips aren't relevant.
final StreamProvider<List<Exercise>> allExercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).watchExercises();
});

final StreamProviderFamily<List<Exercise>, MuscleGroup?> exercisesByMuscleGroupProvider =
    StreamProvider.family<List<Exercise>, MuscleGroup?>((ref, muscleGroup) {
  return ref.watch(exerciseRepositoryProvider).watchExercises(muscleGroup: muscleGroup);
});

final StreamProviderFamily<Exercise?, String> exerciseByIdProvider =
    StreamProvider.family<Exercise?, String>((ref, id) {
  return ref.watch(exerciseRepositoryProvider).watchExercise(id);
});
