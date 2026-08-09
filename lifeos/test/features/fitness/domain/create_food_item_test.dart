import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/food_item.dart';
import 'package:lifeos/features/fitness/domain/entities/food_log_entry.dart';
import 'package:lifeos/features/fitness/domain/entities/meal_type.dart';
import 'package:lifeos/features/fitness/domain/entities/nutrition_goal.dart';
import 'package:lifeos/features/fitness/domain/repositories/nutrition_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/create_food_item.dart';
import 'package:lifeos/features/fitness/domain/usecases/log_food.dart';

class _FakeNutritionRepository implements NutritionRepository {
  FoodItem? savedItem;
  FoodLogEntry? savedLogEntry;

  @override
  Future<Result<FoodItem>> createFoodItem(FoodItem item) async {
    savedItem = item;
    return Result.ok(item);
  }

  @override
  Future<Result<void>> deleteFoodItem(String id) async => const Result.ok(null);

  @override
  Future<Result<FoodItem>> updateFoodItem(FoodItem item) async => Result.ok(item);

  @override
  Stream<FoodItem?> watchFoodItem(String id) => const Stream.empty();

  @override
  Stream<List<FoodItem>> watchActiveFoodItems() => const Stream.empty();

  @override
  Future<Result<void>> deleteLogEntry(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> logFood(FoodLogEntry entry) async {
    savedLogEntry = entry;
    return const Result.ok(null);
  }

  @override
  Stream<List<FoodLogEntry>> watchLogEntriesForDate(DateTime date) => const Stream.empty();

  @override
  Stream<NutritionGoal?> watchGoal() => const Stream.empty();

  @override
  Future<Result<void>> updateGoal(NutritionGoal goal) async => const Result.ok(null);
}

FoodItem _buildItem({
  double calories = 100,
  double protein = 10,
  double carbs = 20,
  double fat = 5,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return FoodItem(
    id: 'f1',
    name: 'Chicken Breast',
    caloriesPerServing: calories,
    proteinG: protein,
    carbsG: carbs,
    fatG: fat,
    createdAt: now,
    updatedAt: now,
  );
}

FoodLogEntry _buildLogEntry(FoodItem item, {double servings = 1}) {
  final DateTime now = DateTime(2026, 1, 1);
  return FoodLogEntry(
    id: 'log1',
    foodItem: item,
    date: now,
    mealType: MealType.breakfast,
    servings: servings,
    createdAt: now,
  );
}

void main() {
  group('CreateFoodItem', () {
    test('persists a valid food item', () async {
      final repo = _FakeNutritionRepository();
      final useCase = CreateFoodItem(repo);

      final result = await useCase(_buildItem());

      expect(result.isOk, isTrue);
      expect(repo.savedItem?.name, 'Chicken Breast');
    });

    test('rejects a blank name', () async {
      final repo = _FakeNutritionRepository();
      final useCase = CreateFoodItem(repo);

      final result = await useCase(_buildItem().copyWith(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedItem, isNull);
    });

    test('rejects negative macro values', () async {
      final repo = _FakeNutritionRepository();
      final useCase = CreateFoodItem(repo);

      final result = await useCase(_buildItem(protein: -1));

      expect(result.isErr, isTrue);
      expect(repo.savedItem, isNull);
    });
  });

  group('LogFood', () {
    test('persists a valid log entry', () async {
      final repo = _FakeNutritionRepository();
      final useCase = LogFood(repo);
      final item = _buildItem();

      final result = await useCase(_buildLogEntry(item));

      expect(result.isOk, isTrue);
      expect(repo.savedLogEntry?.foodItem.id, item.id);
    });

    test('rejects zero servings', () async {
      final repo = _FakeNutritionRepository();
      final useCase = LogFood(repo);
      final item = _buildItem();

      final result = await useCase(_buildLogEntry(item, servings: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedLogEntry, isNull);
    });

    test('rejects negative servings', () async {
      final repo = _FakeNutritionRepository();
      final useCase = LogFood(repo);
      final item = _buildItem();

      final result = await useCase(_buildLogEntry(item, servings: -1));

      expect(result.isErr, isTrue);
      expect(repo.savedLogEntry, isNull);
    });
  });
}
