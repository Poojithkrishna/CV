import 'package:drift/drift.dart';

import 'workout_days_table.dart';
import 'workout_plans_table.dart';

@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();

  /// Null for an ad-hoc workout not tied to any plan. Set null (rather
  /// than cascading) if the plan/day is later deleted — session history
  /// is worth keeping on its own.
  TextColumn get planId =>
      text().nullable().references(WorkoutPlans, #id, onDelete: KeyAction.setNull)();
  TextColumn get dayId =>
      text().nullable().references(WorkoutDays, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
