import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/food_item_mapper.dart';
import 'package:lifeos/features/fitness/data/repositories/food_log_entry_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/food_item.dart';
import 'package:lifeos/features/fitness/domain/entities/food_log_entry.dart';
import 'package:lifeos/features/fitness/domain/entities/meal_type.dart';

FoodItem _buildFood({String id = 'f1', String name = 'Rice', double calories = 200}) {
  final DateTime now = DateTime(2026, 1, 1);
  return FoodItem(id: id, name: name, caloriesPerServing: calories, createdAt: now, updatedAt: now);
}

FoodLogEntry _buildLogEntry({
  String id = 'log1',
  required FoodItem food,
  required DateTime date,
  MealType mealType = MealType.lunch,
  double servings = 1,
}) {
  return FoodLogEntry(
    id: id,
    foodItem: food,
    date: date,
    mealType: mealType,
    servings: servings,
    createdAt: date,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON;')),
    );
  });

  tearDown(() async {
    await database.close();
  });

  final DateTime day = DateTime(2026, 1, 5);

  test('watchLogEntriesForDate joins the resolved food item', () async {
    final food = _buildFood(calories: 250);
    await database.nutritionDao.insertFoodItem(food.toCompanion());
    await database.nutritionDao.insertLogEntry(
      _buildLogEntry(food: food, date: day, servings: 2).toCompanion(),
    );

    final entries = await database.nutritionDao.watchLogEntriesForDate(day).first;

    expect(entries, hasLength(1));
    final entry = entries.single.toDomain();
    expect(entry.foodItem.name, 'Rice');
    expect(entry.servings, 2);
    expect(entry.calories, 500);
  });

  test('entries only surface for their own date', () async {
    final food = _buildFood();
    await database.nutritionDao.insertFoodItem(food.toCompanion());
    await database.nutritionDao.insertLogEntry(
      _buildLogEntry(id: 'log1', food: food, date: day).toCompanion(),
    );
    await database.nutritionDao.insertLogEntry(
      _buildLogEntry(id: 'log2', food: food, date: day.add(const Duration(days: 1))).toCompanion(),
    );

    final entries = await database.nutritionDao.watchLogEntriesForDate(day).first;
    expect(entries, hasLength(1));
  });

  test('database seeds a starter food library and default nutrition goal', () async {
    final foods = await database.nutritionDao.watchActiveFoodItems().first;
    expect(foods, isNotEmpty);

    final goal = await database.nutritionDao.watchGoal().first;
    expect(goal?.dailyCalories, 2000);
  });

  test('deleting a food item cascades to its log entries', () async {
    final food = _buildFood();
    await database.nutritionDao.insertFoodItem(food.toCompanion());
    await database.nutritionDao.insertLogEntry(
      _buildLogEntry(food: food, date: day).toCompanion(),
    );

    await database.nutritionDao.deleteFoodItem(food.id);

    final entries = await database.nutritionDao.watchLogEntriesForDate(day).first;
    expect(entries, isEmpty);
  });
}
