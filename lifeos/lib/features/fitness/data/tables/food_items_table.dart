import 'package:drift/drift.dart';

/// A reusable food/ingredient, similar in spirit to `Exercises` — logged
/// against by many `FoodLogEntries` rather than storing macros on every
/// log row.
@DataClassName('FoodItemRow')
class FoodItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  RealColumn get caloriesPerServing => real().withDefault(const Constant(0))();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  TextColumn get servingLabel => text().withDefault(const Constant('serving'))();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
