import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/entities/meal_type.dart';
import '../daos/nutrition_dao.dart';
import 'food_item_mapper.dart';

extension FoodLogEntryWithItemMapper on FoodLogEntryWithItem {
  FoodLogEntry toDomain() {
    return FoodLogEntry(
      id: entry.id,
      foodItem: item.toDomain(),
      date: entry.date,
      mealType: MealType.values.byName(entry.mealType),
      servings: entry.servings,
      createdAt: entry.createdAt,
    );
  }
}

extension FoodLogEntryCompanionMapper on FoodLogEntry {
  FoodLogEntriesCompanion toCompanion() {
    return FoodLogEntriesCompanion.insert(
      id: id,
      foodItemId: foodItem.id,
      date: date,
      mealType: mealType.name,
      servings: Value(servings),
      createdAt: createdAt,
    );
  }
}
