import 'package:drift/drift.dart';

import 'supplements_table.dart';

/// One entry per supplement per calendar day — toggled by
/// `SupplementsDao.toggleTaken`, mirroring `HabitEntries`.
@DataClassName('SupplementLogEntryRow')
class SupplementLogEntries extends Table {
  TextColumn get id => text()();
  // See milestones_table.dart in the goals feature for why this uses
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get supplementId =>
      text().customConstraint('NOT NULL REFERENCES supplements (id) ON DELETE CASCADE')();
  DateTimeColumn get date => dateTime()();
  BoolColumn get taken => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {supplementId, date},
      ];
}
