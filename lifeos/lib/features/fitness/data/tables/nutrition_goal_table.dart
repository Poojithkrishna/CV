import 'package:drift/drift.dart';

/// The fixed id of the one row this table ever holds.
const String kDefaultNutritionGoalId = 'default';

/// A single-row settings table (fixed `id: 'default'`) for daily
/// nutrition targets — seeded once on database creation, see
/// `AppDatabase._seedDefaultNutritionGoal`.
@DataClassName('NutritionGoalRow')
class NutritionGoals extends Table {
  TextColumn get id => text()();
  RealColumn get dailyCalories => real().withDefault(const Constant(2000))();
  RealColumn get proteinG => real().withDefault(const Constant(150))();
  RealColumn get carbsG => real().withDefault(const Constant(250))();
  RealColumn get fatG => real().withDefault(const Constant(65))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
