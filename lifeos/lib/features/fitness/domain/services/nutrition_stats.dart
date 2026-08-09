import '../entities/food_log_entry.dart';
import '../entities/meal_type.dart';
import '../entities/nutrition_totals.dart';

/// Pure, DB-free macro totaling shared by the daily log screen and (once
/// wired) the dashboard.
class NutritionStats {
  NutritionStats._();

  static NutritionTotals totalsFor(List<FoodLogEntry> entries) {
    NutritionTotals total = const NutritionTotals();
    for (final FoodLogEntry entry in entries) {
      total = total +
          NutritionTotals(
            calories: entry.calories,
            proteinG: entry.proteinG,
            carbsG: entry.carbsG,
            fatG: entry.fatG,
          );
    }
    return total;
  }

  static Map<MealType, List<FoodLogEntry>> groupByMeal(List<FoodLogEntry> entries) {
    final Map<MealType, List<FoodLogEntry>> byMeal = {};
    for (final FoodLogEntry entry in entries) {
      byMeal.putIfAbsent(entry.mealType, () => []).add(entry);
    }
    return byMeal;
  }
}
