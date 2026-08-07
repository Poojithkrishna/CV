import 'package:drift/drift.dart';

import 'exercises_table.dart';
import 'workout_sessions_table.dart';

@DataClassName('LoggedSetRow')
class LoggedSets extends Table {
  TextColumn get id => text()();

  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();

  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();

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
