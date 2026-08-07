import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_session.dart';

extension WorkoutSessionRowMapper on WorkoutSessionRow {
  WorkoutSession toDomain() {
    return WorkoutSession(
      id: id,
      planId: planId,
      dayId: dayId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension WorkoutSessionEntityMapper on WorkoutSession {
  WorkoutSessionsCompanion toCompanion() {
    return WorkoutSessionsCompanion.insert(
      id: id,
      planId: Value(planId),
      dayId: Value(dayId),
      date: date,
      startTime: startTime,
      endTime: Value(endTime),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
