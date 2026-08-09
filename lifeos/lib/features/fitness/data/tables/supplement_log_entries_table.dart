import 'package:drift/drift.dart';

import 'supplements_table.dart';

/// One entry per supplement per calendar day — toggled by
/// `SupplementsDao.toggleTaken`, mirroring `HabitEntries`.
@DataClassName('SupplementLogEntryRow')
class SupplementLogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get supplementId =>
      text().references(Supplements, #id, onDelete: KeyAction.cascade)();
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
