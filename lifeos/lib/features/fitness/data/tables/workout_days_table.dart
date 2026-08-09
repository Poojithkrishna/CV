import 'package:drift/drift.dart';

@DataClassName('WorkoutDayRow')
class WorkoutDays extends Table {
  TextColumn get id => text()();

  // See milestones_table.dart in the goals feature for why this uses
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get planId =>
      text().customConstraint('NOT NULL REFERENCES workout_plans (id) ON DELETE CASCADE')();

  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
