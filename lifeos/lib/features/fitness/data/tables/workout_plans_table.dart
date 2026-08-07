import 'package:drift/drift.dart';

@DataClassName('WorkoutPlanRow')
class WorkoutPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Stored as [WorkoutPlanType.name].
  TextColumn get type => text()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
