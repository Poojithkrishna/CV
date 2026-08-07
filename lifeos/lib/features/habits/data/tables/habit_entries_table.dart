import 'package:drift/drift.dart';

import 'habits_table.dart';

@DataClassName('HabitEntryRow')
class HabitEntries extends Table {
  TextColumn get id => text()();

  TextColumn get habitId => text().references(Habits, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get periodStart => dateTime()();
  RealColumn get progressValue => real().withDefault(const Constant(0))();

  /// Comma-separated indices into the parent habit's checklist items.
  TextColumn get checkedItemIndices => text().nullable()();

  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, periodStart},
      ];
}
