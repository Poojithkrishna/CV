import 'package:drift/drift.dart';

/// The fixed id of the one row this table ever holds.
const String kDefaultContentGoalId = 'default';

/// A single-row settings table (fixed `id: 'default'`) for the weekly
/// upload target — seeded once on database creation, see
/// `AppDatabase._seedDefaultContentGoal`.
@DataClassName('ContentGoalRow')
class ContentGoals extends Table {
  TextColumn get id => text()();
  IntColumn get weeklyUploadTarget => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
