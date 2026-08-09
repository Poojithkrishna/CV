import 'package:drift/drift.dart';

import 'app_database.dart';

/// Starter food library seeded the first time the database is created,
/// covering common staples so a meal can be logged immediately. Fixed
/// ids for stability across reinstalls; users can add, edit or archive
/// any of them freely. Macro values are per the given serving — rough
/// reference figures, not a nutrition database.
List<FoodItemsCompanion> buildDefaultFoodSeed(DateTime now) {
  FoodItemsCompanion food({
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String servingLabel = 'serving',
  }) {
    return FoodItemsCompanion.insert(
      id: id,
      name: name,
      caloriesPerServing: Value(calories),
      proteinG: Value(protein),
      carbsG: Value(carbs),
      fatG: Value(fat),
      servingLabel: Value(servingLabel),
      isArchived: const Value(false),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    food(id: 'seed-food-rice', name: 'White Rice (cooked)', calories: 205, protein: 4.3, carbs: 45, fat: 0.4, servingLabel: 'cup'),
    food(id: 'seed-food-chicken-breast', name: 'Chicken Breast (grilled)', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingLabel: '100 g'),
    food(id: 'seed-food-egg', name: 'Egg (whole)', calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3, servingLabel: '1 egg'),
    food(id: 'seed-food-banana', name: 'Banana', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, servingLabel: '1 medium'),
    food(id: 'seed-food-oats', name: 'Rolled Oats (dry)', calories: 150, protein: 5, carbs: 27, fat: 2.5, servingLabel: '40 g'),
    food(id: 'seed-food-milk', name: 'Milk (whole)', calories: 149, protein: 8, carbs: 12, fat: 8, servingLabel: 'cup'),
    food(id: 'seed-food-bread', name: 'Whole Wheat Bread', calories: 81, protein: 4, carbs: 14, fat: 1.1, servingLabel: '1 slice'),
    food(id: 'seed-food-apple', name: 'Apple', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, servingLabel: '1 medium'),
    food(id: 'seed-food-almonds', name: 'Almonds', calories: 164, protein: 6, carbs: 6, fat: 14, servingLabel: '28 g'),
    food(id: 'seed-food-dal', name: 'Lentil Dal (cooked)', calories: 230, protein: 18, carbs: 40, fat: 0.8, servingLabel: 'cup'),
    food(id: 'seed-food-roti', name: 'Roti / Chapati', calories: 120, protein: 3.5, carbs: 20, fat: 3, servingLabel: '1 piece'),
    food(id: 'seed-food-paneer', name: 'Paneer', calories: 265, protein: 18, carbs: 6, fat: 20, servingLabel: '100 g'),
    food(id: 'seed-food-yogurt', name: 'Plain Yogurt', calories: 149, protein: 8.5, carbs: 11, fat: 8, servingLabel: 'cup'),
    food(id: 'seed-food-salad', name: 'Mixed Green Salad', calories: 20, protein: 1.5, carbs: 4, fat: 0.2, servingLabel: 'bowl'),
    food(id: 'seed-food-salmon', name: 'Salmon (grilled)', calories: 206, protein: 22, carbs: 0, fat: 13, servingLabel: '100 g'),
    food(id: 'seed-food-peanut-butter', name: 'Peanut Butter', calories: 94, protein: 4, carbs: 3, fat: 8, servingLabel: '1 tbsp'),
  ];
}
