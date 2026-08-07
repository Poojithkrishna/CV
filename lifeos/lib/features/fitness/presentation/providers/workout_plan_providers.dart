import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/workout_plans_dao.dart';
import '../../data/repositories/workout_plan_repository_impl.dart';
import '../../domain/entities/plan_exercise.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_plan_repository.dart';
import '../../domain/usecases/add_exercise_to_day.dart';
import '../../domain/usecases/create_workout_day.dart';
import '../../domain/usecases/create_workout_plan.dart';
import '../../domain/usecases/delete_workout_day.dart';
import '../../domain/usecases/delete_workout_plan.dart';
import '../../domain/usecases/remove_exercise_from_day.dart';
import '../../domain/usecases/set_active_plan.dart';
import '../../domain/usecases/update_plan_exercise.dart';
import '../../domain/usecases/update_workout_day.dart';
import '../../domain/usecases/update_workout_plan.dart';

final Provider<WorkoutPlansDao> workoutPlansDaoProvider = Provider<WorkoutPlansDao>((ref) {
  return WorkoutPlansDao(ref.watch(appDatabaseProvider));
});

final Provider<WorkoutPlanRepository> workoutPlanRepositoryProvider =
    Provider<WorkoutPlanRepository>((ref) {
  return WorkoutPlanRepositoryImpl(ref.watch(workoutPlansDaoProvider));
});

final Provider<CreateWorkoutPlan> createWorkoutPlanUseCaseProvider = Provider(
  (ref) => CreateWorkoutPlan(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<UpdateWorkoutPlan> updateWorkoutPlanUseCaseProvider = Provider(
  (ref) => UpdateWorkoutPlan(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<DeleteWorkoutPlan> deleteWorkoutPlanUseCaseProvider = Provider(
  (ref) => DeleteWorkoutPlan(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<SetActivePlan> setActivePlanUseCaseProvider = Provider(
  (ref) => SetActivePlan(ref.watch(workoutPlanRepositoryProvider)),
);

final Provider<CreateWorkoutDay> createWorkoutDayUseCaseProvider = Provider(
  (ref) => CreateWorkoutDay(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<UpdateWorkoutDay> updateWorkoutDayUseCaseProvider = Provider(
  (ref) => UpdateWorkoutDay(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<DeleteWorkoutDay> deleteWorkoutDayUseCaseProvider = Provider(
  (ref) => DeleteWorkoutDay(ref.watch(workoutPlanRepositoryProvider)),
);

final Provider<AddExerciseToDay> addExerciseToDayUseCaseProvider = Provider(
  (ref) => AddExerciseToDay(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<UpdatePlanExercise> updatePlanExerciseUseCaseProvider = Provider(
  (ref) => UpdatePlanExercise(ref.watch(workoutPlanRepositoryProvider)),
);
final Provider<RemoveExerciseFromDay> removeExerciseFromDayUseCaseProvider = Provider(
  (ref) => RemoveExerciseFromDay(ref.watch(workoutPlanRepositoryProvider)),
);

final StreamProvider<List<WorkoutPlan>> activePlansProvider = StreamProvider<List<WorkoutPlan>>((ref) {
  return ref.watch(workoutPlanRepositoryProvider).watchActivePlans();
});

final StreamProviderFamily<WorkoutPlan?, String> workoutPlanByIdProvider =
    StreamProvider.family<WorkoutPlan?, String>((ref, id) {
  return ref.watch(workoutPlanRepositoryProvider).watchPlan(id);
});

/// The single currently-active plan, if any — used by the dashboard and
/// the workout-start flow.
final StreamProvider<WorkoutPlan?> currentActivePlanProvider = StreamProvider<WorkoutPlan?>((ref) {
  return ref.watch(workoutPlanRepositoryProvider).watchCurrentActivePlan();
});

final StreamProviderFamily<List<WorkoutDay>, String> daysForPlanProvider =
    StreamProvider.family<List<WorkoutDay>, String>((ref, planId) {
  return ref.watch(workoutPlanRepositoryProvider).watchDaysForPlan(planId);
});

final StreamProviderFamily<List<PlanExercise>, String> exercisesForDayProvider =
    StreamProvider.family<List<PlanExercise>, String>((ref, dayId) {
  return ref.watch(workoutPlanRepositoryProvider).watchExercisesForDay(dayId);
});
