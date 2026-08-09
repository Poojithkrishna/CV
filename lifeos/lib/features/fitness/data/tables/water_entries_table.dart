import 'package:drift/drift.dart';

/// One accumulating row per calendar day — each "add water" tap calls
/// `WaterDao.logWater`, which adds a delta to the day's total rather than
/// inserting a new row, mirroring `HabitsDao.logProgress`.
@DataClassName('WaterEntryRow')
class WaterEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountMl => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
}
