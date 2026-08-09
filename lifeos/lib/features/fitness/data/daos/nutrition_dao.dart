import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/food_items_table.dart';
import '../tables/food_log_entries_table.dart';
import '../tables/nutrition_goal_table.dart';

part 'nutrition_dao.g.dart';

/// Pairs a logged serving with its resolved food item — what
/// `watchLogEntriesForDate`'s join query returns, before mapping to the
/// domain `FoodLogEntry` (which embeds the food item directly).
class FoodLogEntryWithItem {
  FoodLogEntryWithItem(this.entry, this.item);

  final FoodLogEntryRow entry;
  final FoodItemRow item;
}

@DriftAccessor(tables: [FoodItems, FoodLogEntries, NutritionGoals])
class NutritionDao extends DatabaseAccessor<AppDatabase> with _$NutritionDaoMixin {
  NutritionDao(super.db);

  // --- Food library ---

  Stream<List<FoodItemRow>> watchActiveFoodItems() {
    return (select(foodItems)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .watch();
  }

  Stream<FoodItemRow?> watchFoodItem(String id) {
    return (select(foodItems)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertFoodItem(FoodItemsCompanion entry) {
    return into(foodItems).insert(entry);
  }

  Future<bool> updateFoodItem(FoodItemsCompanion entry) {
    return update(foodItems).replace(entry);
  }

  Future<int> deleteFoodItem(String id) {
    return (delete(foodItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Daily log ---

  Stream<List<FoodLogEntryWithItem>> watchLogEntriesForDate(DateTime date) {
    final query = select(foodLogEntries).join([
      innerJoin(foodItems, foodItems.id.equalsExp(foodLogEntries.foodItemId)),
    ])
      ..where(foodLogEntries.date.equals(date))
      ..orderBy([OrderingTerm.asc(foodLogEntries.createdAt)]);
    return query.watch().map(
          (rows) => rows
              .map((row) => FoodLogEntryWithItem(
                    row.readTable(foodLogEntries),
                    row.readTable(foodItems),
                  ))
              .toList(growable: false),
        );
  }

  Future<void> insertLogEntry(FoodLogEntriesCompanion entry) {
    return into(foodLogEntries).insert(entry);
  }

  Future<int> deleteLogEntry(String id) {
    return (delete(foodLogEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Goal ---

  Stream<NutritionGoalRow?> watchGoal() {
    return (select(nutritionGoals)..where((tbl) => tbl.id.equals(kDefaultNutritionGoalId)))
        .watchSingleOrNull();
  }

  Future<void> updateGoal(NutritionGoalsCompanion entry) {
    return into(nutritionGoals).insertOnConflictUpdate(entry);
  }
}
