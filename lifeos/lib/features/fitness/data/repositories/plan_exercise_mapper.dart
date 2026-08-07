import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/plan_exercise.dart';

extension PlanExerciseRowMapper on PlanExerciseRow {
  PlanExercise toDomain() {
    return PlanExercise(
      id: id,
      dayId: dayId,
      exerciseId: exerciseId,
      targetSets: targetSets,
      targetReps: targetReps,
      targetWeight: targetWeight,
      restSeconds: restSeconds,
      sortOrder: sortOrder,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension PlanExerciseEntityMapper on PlanExercise {
  PlanExercisesCompanion toCompanion() {
    return PlanExercisesCompanion.insert(
      id: id,
      dayId: dayId,
      exerciseId: exerciseId,
      targetSets: targetSets,
      targetReps: targetReps,
      targetWeight: Value(targetWeight),
      restSeconds: Value(restSeconds),
      sortOrder: Value(sortOrder),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
