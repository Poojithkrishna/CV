import 'package:drift/drift.dart';

@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();

  /// Null for an ad-hoc workout not tied to any plan. Set null (rather
  /// than cascading) if the plan/day is later deleted — session history
  /// is worth keeping on its own. Uses `.customConstraint()` rather than
  /// `.references()` — see milestones_table.dart in the goals feature
  /// for why (the latter's generated constraint was silently dropped by
  /// drift_dev in this schema).
  TextColumn get planId =>
      text().nullable().customConstraint('REFERENCES workout_plans (id) ON DELETE SET NULL')();
  TextColumn get dayId =>
      text().nullable().customConstraint('REFERENCES workout_days (id) ON DELETE SET NULL')();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
