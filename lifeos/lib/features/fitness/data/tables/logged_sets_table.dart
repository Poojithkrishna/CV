import 'package:drift/drift.dart';

import 'exercises_table.dart';
import 'workout_sessions_table.dart';

@DataClassName('LoggedSetRow')
class LoggedSets extends Table {
  TextColumn get id => text()();

  // See milestones_table.dart in the goals feature for why these use
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get sessionId =>
      text().customConstraint('NOT NULL REFERENCES workout_sessions (id) ON DELETE CASCADE')();

  TextColumn get exerciseId =>
      text().customConstraint('NOT NULL REFERENCES exercises (id) ON DELETE CASCADE')();

  IntColumn get setNumber => integer()();
  IntColumn get reps => integer()();
  RealColumn get weight => real()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  /// Whether this was the heaviest weight ever logged for this exercise
  /// at the time it was logged.
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
