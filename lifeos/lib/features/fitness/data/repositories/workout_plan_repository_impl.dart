import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/plan_exercise.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/repositories/workout_plan_repository.dart';
import '../daos/workout_plans_dao.dart';
import 'plan_exercise_mapper.dart';
import 'workout_day_mapper.dart';
import 'workout_plan_mapper.dart';

class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  WorkoutPlanRepositoryImpl(this._dao);

  final WorkoutPlansDao _dao;

  @override
  Stream<List<WorkoutPlan>> watchActivePlans() {
    return _dao
        .watchActivePlans()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<WorkoutPlan?> watchPlan(String id) {
    return _dao.watchPlan(id).map((row) => row?.toDomain());
  }

  @override
  Stream<WorkoutPlan?> watchCurrentActivePlan() {
    return _dao.watchCurrentActivePlan().map((row) => row?.toDomain());
  }

  @override
  Future<Result<WorkoutPlan>> createPlan(WorkoutPlan plan) async {
    try {
      await _dao.insertPlan(plan.toCompanion());
      return Result.ok(plan);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save plan: $e'));
    }
  }

  @override
  Future<Result<WorkoutPlan>> updatePlan(WorkoutPlan plan) async {
    try {
      final bool updated = await _dao.updatePlan(plan.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Plan no longer exists.'));
      }
      return Result.ok(plan);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update plan: $e'));
    }
  }

  @override
  Future<Result<void>> deletePlan(String id) async {
    try {
      await _dao.deletePlan(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete plan: $e'));
    }
  }

  @override
  Future<Result<void>> setActivePlan(String id) async {
    try {
      await _dao.setActivePlan(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not switch plan: $e'));
    }
  }

  @override
  Stream<List<WorkoutDay>> watchDaysForPlan(String planId) {
    return _dao
        .watchDaysForPlan(planId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<WorkoutDay>> createDay(WorkoutDay day) async {
    try {
      await _dao.insertDay(day.toCompanion());
      return Result.ok(day);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save day: $e'));
    }
  }

  @override
  Future<Result<WorkoutDay>> updateDay(WorkoutDay day) async {
    try {
      final bool updated = await _dao.updateDay(day.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Day no longer exists.'));
      }
      return Result.ok(day);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update day: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDay(String id) async {
    try {
      await _dao.deleteDay(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete day: $e'));
    }
  }

  @override
  Stream<List<PlanExercise>> watchExercisesForDay(String dayId) {
    return _dao
        .watchExercisesForDay(dayId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<PlanExercise>> addExerciseToDay(PlanExercise planExercise) async {
    try {
      await _dao.insertPlanExercise(planExercise.toCompanion());
      return Result.ok(planExercise);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not add exercise: $e'));
    }
  }

  @override
  Future<Result<PlanExercise>> updatePlanExercise(PlanExercise planExercise) async {
    try {
      final bool updated = await _dao.updatePlanExercise(planExercise.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Exercise entry no longer exists.'));
      }
      return Result.ok(planExercise);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update exercise entry: $e'));
    }
  }

  @override
  Future<Result<void>> removeExerciseFromDay(String id) async {
    try {
      await _dao.deletePlanExercise(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not remove exercise: $e'));
    }
  }
}
