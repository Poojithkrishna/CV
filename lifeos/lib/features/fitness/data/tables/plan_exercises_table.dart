import 'package:drift/drift.dart';

@DataClassName('PlanExerciseRow')
class PlanExercises extends Table {
  TextColumn get id => text()();

  // See milestones_table.dart in the goals feature for why these use
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get dayId =>
      text().customConstraint('NOT NULL REFERENCES workout_days (id) ON DELETE CASCADE')();

  TextColumn get exerciseId =>
      text().customConstraint('NOT NULL REFERENCES exercises (id) ON DELETE CASCADE')();

  IntColumn get targetSets => integer()();

  /// Free-form so it can express a range, e.g. `"8-12"`.
  TextColumn get targetReps => text()();

  RealColumn get targetWeight => real().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
