import 'package:drift/drift.dart';

@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Stored as [HabitType.name].
  TextColumn get type => text()();

  /// Stored as [HabitFrequency.name].
  TextColumn get frequency => text()();

  RealColumn get targetValue => real().withDefault(const Constant(1))();
  TextColumn get unit => text().nullable()();

  /// Comma-separated weekday ints (1 = Monday .. 7 = Sunday), only used
  /// when frequency is `custom`.
  TextColumn get customWeekdays => text().nullable()();

  /// Newline-separated checklist item labels, only used for the
  /// checklist habit type.
  TextColumn get checklistItems => text().nullable()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
