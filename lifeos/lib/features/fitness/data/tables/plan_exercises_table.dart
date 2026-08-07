import 'package:drift/drift.dart';

import 'exercises_table.dart';
import 'workout_days_table.dart';

@DataClassName('PlanExerciseRow')
class PlanExercises extends Table {
  TextColumn get id => text()();

  TextColumn get dayId => text().references(WorkoutDays, #id, onDelete: KeyAction.cascade)();

  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();

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
