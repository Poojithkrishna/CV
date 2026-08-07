import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/plan_exercises_table.dart';
import '../tables/workout_days_table.dart';
import '../tables/workout_plans_table.dart';

part 'workout_plans_dao.g.dart';

/// Owns the whole plan structure (plans, their days, and each day's
/// exercises) since they're really one aggregate — a plan doesn't mean
/// much without its days, and a day doesn't mean much without its
/// exercises.
@DriftAccessor(tables: [WorkoutPlans, WorkoutDays, PlanExercises])
class WorkoutPlansDao extends DatabaseAccessor<AppDatabase> with _$WorkoutPlansDaoMixin {
  WorkoutPlansDao(super.db);

  // --- Plans ---

  Stream<List<WorkoutPlanRow>> watchActivePlans() {
    return (select(workoutPlans)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.isActive), (tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<WorkoutPlanRow?> watchPlan(String id) {
    return (select(workoutPlans)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Stream<WorkoutPlanRow?> watchCurrentActivePlan() {
    return (select(workoutPlans)
          ..where((tbl) => tbl.isActive.equals(true) & tbl.isArchived.equals(false)))
        .watchSingleOrNull();
  }

  Future<void> insertPlan(WorkoutPlansCompanion entry) {
    return into(workoutPlans).insert(entry);
  }

  Future<bool> updatePlan(WorkoutPlansCompanion entry) {
    return update(workoutPlans).replace(entry);
  }

  Future<int> deletePlan(String id) {
    return (delete(workoutPlans)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Marks [planId] active and every other plan inactive, atomically —
  /// enforces "only one active plan at a time" without a unique index.
  Future<void> setActivePlan(String planId) {
    return transaction(() async {
      await update(workoutPlans).write(const WorkoutPlansCompanion(isActive: Value(false)));
      await (update(workoutPlans)..where((tbl) => tbl.id.equals(planId)))
          .write(const WorkoutPlansCompanion(isActive: Value(true)));
    });
  }

  // --- Days ---

  Stream<List<WorkoutDayRow>> watchDaysForPlan(String planId) {
    return (select(workoutDays)
          ..where((tbl) => tbl.planId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Future<void> insertDay(WorkoutDaysCompanion entry) {
    return into(workoutDays).insert(entry);
  }

  Future<bool> updateDay(WorkoutDaysCompanion entry) {
    return update(workoutDays).replace(entry);
  }

  Future<int> deleteDay(String id) {
    return (delete(workoutDays)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Plan exercises ---

  Stream<List<PlanExerciseRow>> watchExercisesForDay(String dayId) {
    return (select(planExercises)
          ..where((tbl) => tbl.dayId.equals(dayId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Future<void> insertPlanExercise(PlanExercisesCompanion entry) {
    return into(planExercises).insert(entry);
  }

  Future<bool> updatePlanExercise(PlanExercisesCompanion entry) {
    return update(planExercises).replace(entry);
  }

  Future<int> deletePlanExercise(String id) {
    return (delete(planExercises)..where((tbl) => tbl.id.equals(id))).go();
  }
}
