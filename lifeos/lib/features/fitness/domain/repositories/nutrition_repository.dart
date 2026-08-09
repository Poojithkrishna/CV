import '../../../../core/utils/result.dart';
import '../entities/food_item.dart';
import '../entities/food_log_entry.dart';
import '../entities/nutrition_goal.dart';

abstract interface class NutritionRepository {
  Stream<List<FoodItem>> watchActiveFoodItems();
  Stream<FoodItem?> watchFoodItem(String id);
  Future<Result<FoodItem>> createFoodItem(FoodItem item);
  Future<Result<FoodItem>> updateFoodItem(FoodItem item);
  Future<Result<void>> deleteFoodItem(String id);

  Stream<List<FoodLogEntry>> watchLogEntriesForDate(DateTime date);
  Future<Result<void>> logFood(FoodLogEntry entry);
  Future<Result<void>> deleteLogEntry(String id);

  Stream<NutritionGoal?> watchGoal();
  Future<Result<void>> updateGoal(NutritionGoal goal);
}
