import 'package:drift/drift.dart';

/// One row per calendar day the app was opened — captures whatever Life
/// Score, XP and rank were live at the time, so opening the app again
/// later the same day updates that day's row rather than creating a
/// second one (see `GamificationDao.upsertTodaysSnapshot`, mirroring
/// `BodyWeightDao.upsertForDate`). There's no background job recomputing
/// history retroactively — like the home screen widget, this is only as
/// fresh as the last time the app was open.
@DataClassName('LifeScoreSnapshotRow')
class LifeScoreSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get lifeScore => real()();
  IntColumn get xp => integer()();
  IntColumn get rankIndex => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
}
