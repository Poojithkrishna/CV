import 'package:drift/drift.dart';

/// The fixed id of the one row this table ever holds.
const String kDefaultWaterGoalId = 'default';

/// A single-row settings table (fixed `id: 'default'`) for the daily
/// water target — seeded once on database creation, see
/// `AppDatabase._seedDefaultWaterGoal`.
@DataClassName('WaterGoalRow')
class WaterGoals extends Table {
  TextColumn get id => text()();
  IntColumn get dailyGoalMl => integer().withDefault(const Constant(2500))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
