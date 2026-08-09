import 'package:drift/drift.dart';

/// One entry per body-part per calendar day — logging the same type
/// again on the same day overwrites it rather than creating a second
/// row, matching `BodyWeightEntries`.
@DataClassName('MeasurementEntryRow')
class MeasurementEntries extends Table {
  TextColumn get id => text()();

  /// Stored as [MeasurementType.name].
  TextColumn get type => text()();

  DateTimeColumn get date => dateTime()();
  RealColumn get valueCm => real()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {type, date},
      ];
}
