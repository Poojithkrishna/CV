import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/food_item.dart';
import 'package:lifeos/features/fitness/domain/entities/food_log_entry.dart';
import 'package:lifeos/features/fitness/domain/entities/meal_type.dart';
import 'package:lifeos/features/fitness/domain/entities/nutrition_totals.dart';
import 'package:lifeos/features/fitness/domain/services/nutrition_stats.dart';

FoodItem _food({
  String id = 'f1',
  double calories = 100,
  double protein = 10,
  double carbs = 20,
  double fat = 5,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return FoodItem(
    id: id,
    name: 'Food $id',
    caloriesPerServing: calories,
    proteinG: protein,
    carbsG: carbs,
    fatG: fat,
    createdAt: now,
    updatedAt: now,
  );
}

FoodLogEntry _entry(FoodItem food, {double servings = 1, MealType mealType = MealType.breakfast}) {
  return FoodLogEntry(
    id: 'log-${food.id}-$mealType-$servings',
    foodItem: food,
    date: DateTime(2026, 1, 1),
    mealType: mealType,
    servings: servings,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('NutritionStats.totalsFor', () {
    test('sums calories and macros scaled by servings', () {
      final food = _food(calories: 200, protein: 20, carbs: 30, fat: 8);
      final entries = [
        _entry(food, servings: 1),
        _entry(food, servings: 2, mealType: MealType.dinner),
      ];

      final NutritionTotals totals = NutritionStats.totalsFor(entries);

      expect(totals.calories, 600);
      expect(totals.proteinG, 60);
      expect(totals.carbsG, 90);
      expect(totals.fatG, 24);
    });

    test('returns all zeros for an empty log', () {
      final NutritionTotals totals = NutritionStats.totalsFor(const []);
      expect(totals.calories, 0);
      expect(totals.proteinG, 0);
      expect(totals.carbsG, 0);
      expect(totals.fatG, 0);
    });
  });

  group('NutritionStats.groupByMeal', () {
    test('buckets entries by meal type', () {
      final food = _food();
      final entries = [
        _entry(food, mealType: MealType.breakfast),
        _entry(food, mealType: MealType.breakfast, servings: 2),
        _entry(food, mealType: MealType.lunch),
      ];

      final grouped = NutritionStats.groupByMeal(entries);

      expect(grouped[MealType.breakfast]?.length, 2);
      expect(grouped[MealType.lunch]?.length, 1);
      expect(grouped[MealType.dinner], isNull);
    });
  });
}
