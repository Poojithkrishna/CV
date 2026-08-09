import 'package:drift/drift.dart';

/// One entry per calendar day — logging again for a day already logged
/// overwrites it, mirroring `BodyWeightEntries`.
@DataClassName('RecoveryEntryRow')
class RecoveryEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get sleepHours => real().nullable()();
  IntColumn get sorenessLevel => integer().nullable()();
  IntColumn get stressLevel => integer().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
}
