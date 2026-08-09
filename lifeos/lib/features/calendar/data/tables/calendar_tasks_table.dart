import 'package:drift/drift.dart';

@DataClassName('CalendarTaskRow')
class CalendarTasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isTimeBlocked => boolean().withDefault(const Constant(false))();

  /// Stored as [TaskPriority.name].
  TextColumn get priority => text()();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
