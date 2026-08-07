import 'package:drift/drift.dart';

import 'workout_plans_table.dart';

@DataClassName('WorkoutDayRow')
class WorkoutDays extends Table {
  TextColumn get id => text()();

  TextColumn get planId =>
      text().references(WorkoutPlans, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
