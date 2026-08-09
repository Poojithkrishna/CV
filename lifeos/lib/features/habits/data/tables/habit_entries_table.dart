import 'package:drift/drift.dart';

@DataClassName('HabitEntryRow')
class HabitEntries extends Table {
  TextColumn get id => text()();

  // See milestones_table.dart in the goals feature for why this uses
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get habitId =>
      text().customConstraint('NOT NULL REFERENCES habits (id) ON DELETE CASCADE')();

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
