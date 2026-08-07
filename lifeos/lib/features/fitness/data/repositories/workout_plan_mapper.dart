import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/workout_plan_type.dart';

extension WorkoutPlanRowMapper on WorkoutPlanRow {
  WorkoutPlan toDomain() {
    return WorkoutPlan(
      id: id,
      name: name,
      type: WorkoutPlanType.values.byName(type),
      notes: notes,
      isActive: isActive,
      isArchived: isArchived,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension WorkoutPlanEntityMapper on WorkoutPlan {
  WorkoutPlansCompanion toCompanion() {
    return WorkoutPlansCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      notes: Value(notes),
      isActive: Value(isActive),
      isArchived: Value(isArchived),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
