import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_day.dart';

extension WorkoutDayRowMapper on WorkoutDayRow {
  WorkoutDay toDomain() {
    return WorkoutDay(
      id: id,
      planId: planId,
      name: name,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension WorkoutDayEntityMapper on WorkoutDay {
  WorkoutDaysCompanion toCompanion() {
    return WorkoutDaysCompanion.insert(
      id: id,
      planId: planId,
      name: name,
      sortOrder: Value(sortOrder),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
