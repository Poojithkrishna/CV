import '../../../../core/utils/result.dart';
import '../entities/plan_exercise.dart';
import '../entities/workout_day.dart';
import '../entities/workout_plan.dart';

abstract interface class WorkoutPlanRepository {
  Stream<List<WorkoutPlan>> watchActivePlans();
  Stream<WorkoutPlan?> watchPlan(String id);
  Stream<WorkoutPlan?> watchCurrentActivePlan();

  Future<Result<WorkoutPlan>> createPlan(WorkoutPlan plan);
  Future<Result<WorkoutPlan>> updatePlan(WorkoutPlan plan);
  Future<Result<void>> deletePlan(String id);
  Future<Result<void>> setActivePlan(String id);

  Stream<List<WorkoutDay>> watchDaysForPlan(String planId);
  Future<Result<WorkoutDay>> createDay(WorkoutDay day);
  Future<Result<WorkoutDay>> updateDay(WorkoutDay day);
  Future<Result<void>> deleteDay(String id);

  Stream<List<PlanExercise>> watchExercisesForDay(String dayId);
  Future<Result<PlanExercise>> addExerciseToDay(PlanExercise planExercise);
  Future<Result<PlanExercise>> updatePlanExercise(PlanExercise planExercise);
  Future<Result<void>> removeExerciseFromDay(String id);
}
