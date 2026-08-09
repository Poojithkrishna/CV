import 'package:drift/drift.dart';

import 'food_items_table.dart';

@DataClassName('FoodLogEntryRow')
class FoodLogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get foodItemId =>
      text().references(FoodItems, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  /// Stored as [MealType.name].
  TextColumn get mealType => text()();

  RealColumn get servings => real().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
