import 'package:drift/drift.dart';

/// One entry per calendar day — logging again for a day already logged
/// overwrites it rather than creating a second row (see
/// `BodyWeightDao.upsertForDate`).
@DataClassName('BodyWeightEntryRow')
class BodyWeightEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real()();
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
