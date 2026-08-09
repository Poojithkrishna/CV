import 'package:flutter/foundation.dart';

import 'food_item.dart';
import 'meal_type.dart';

/// A single logged serving. Embeds the resolved [foodItem] (joined by
/// `NutritionDao.watchLogEntriesForDate`) rather than just its id, so a
/// day's totals can be computed without a second round-trip — see
/// `NutritionStats.totalsFor`.
@immutable
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.foodItem,
    required this.date,
    required this.mealType,
    required this.createdAt,
    this.servings = 1,
  });

  final String id;
  final FoodItem foodItem;
  final DateTime date;
  final MealType mealType;
  final double servings;
  final DateTime createdAt;

  double get calories => foodItem.caloriesPerServing * servings;
  double get proteinG => foodItem.proteinG * servings;
  double get carbsG => foodItem.carbsG * servings;
  double get fatG => foodItem.fatG * servings;

  @override
  bool operator ==(Object other) => other is FoodLogEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
