import 'package:drift/drift.dart';

import 'food_items_table.dart';

@DataClassName('FoodLogEntryRow')
class FoodLogEntries extends Table {
  TextColumn get id => text()();
  // See milestones_table.dart in the goals feature for why this uses
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get foodItemId =>
      text().customConstraint('NOT NULL REFERENCES food_items (id) ON DELETE CASCADE')();

  DateTimeColumn get date => dateTime()();

  /// Stored as [MealType.name].
  TextColumn get mealType => text()();

  RealColumn get servings => real().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
