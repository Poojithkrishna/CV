import 'package:drift/drift.dart';

@DataClassName('CardioSessionRow')
class CardioSessions extends Table {
  TextColumn get id => text()();

  /// Stored as [CardioType.name].
  TextColumn get type => text()();

  DateTimeColumn get date => dateTime()();
  RealColumn get durationMinutes => real().withDefault(const Constant(0))();
  RealColumn get distanceKm => real().nullable()();
  RealColumn get caloriesBurned => real().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
