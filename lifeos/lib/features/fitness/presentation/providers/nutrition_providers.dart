import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/nutrition_dao.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/entities/nutrition_totals.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../domain/services/nutrition_stats.dart';
import '../../domain/usecases/create_food_item.dart';
import '../../domain/usecases/delete_food_item.dart';
import '../../domain/usecases/delete_food_log_entry.dart';
import '../../domain/usecases/log_food.dart';
import '../../domain/usecases/update_food_item.dart';
import '../../domain/usecases/update_nutrition_goal.dart';

final Provider<NutritionDao> nutritionDaoProvider = Provider<NutritionDao>((ref) {
  return NutritionDao(ref.watch(appDatabaseProvider));
});

final Provider<NutritionRepository> nutritionRepositoryProvider =
    Provider<NutritionRepository>((ref) {
  return NutritionRepositoryImpl(ref.watch(nutritionDaoProvider));
});

final Provider<CreateFoodItem> createFoodItemUseCaseProvider = Provider(
  (ref) => CreateFoodItem(ref.watch(nutritionRepositoryProvider)),
);
final Provider<UpdateFoodItem> updateFoodItemUseCaseProvider = Provider(
  (ref) => UpdateFoodItem(ref.watch(nutritionRepositoryProvider)),
);
final Provider<DeleteFoodItem> deleteFoodItemUseCaseProvider = Provider(
  (ref) => DeleteFoodItem(ref.watch(nutritionRepositoryProvider)),
);
final Provider<LogFood> logFoodUseCaseProvider = Provider(
  (ref) => LogFood(ref.watch(nutritionRepositoryProvider)),
);
final Provider<DeleteFoodLogEntry> deleteFoodLogEntryUseCaseProvider = Provider(
  (ref) => DeleteFoodLogEntry(ref.watch(nutritionRepositoryProvider)),
);
final Provider<UpdateNutritionGoal> updateNutritionGoalUseCaseProvider = Provider(
  (ref) => UpdateNutritionGoal(ref.watch(nutritionRepositoryProvider)),
);

final StreamProvider<List<FoodItem>> activeFoodItemsProvider = StreamProvider<List<FoodItem>>((ref) {
  return ref.watch(nutritionRepositoryProvider).watchActiveFoodItems();
});

final StreamProviderFamily<FoodItem?, String> foodItemByIdProvider =
    StreamProvider.family<FoodItem?, String>((ref, id) {
  return ref.watch(nutritionRepositoryProvider).watchFoodItem(id);
});

DateTime _normalizeDay(DateTime date) => DateTime(date.year, date.month, date.day);

final StreamProviderFamily<List<FoodLogEntry>, DateTime> logEntriesForDateProvider =
    StreamProvider.family<List<FoodLogEntry>, DateTime>((ref, date) {
  return ref.watch(nutritionRepositoryProvider).watchLogEntriesForDate(_normalizeDay(date));
});

final StreamProvider<List<FoodLogEntry>> todayLogEntriesProvider =
    StreamProvider<List<FoodLogEntry>>((ref) {
  return ref.watch(nutritionRepositoryProvider).watchLogEntriesForDate(_normalizeDay(DateTime.now()));
});

final Provider<AsyncValue<NutritionTotals>> todayNutritionTotalsProvider =
    Provider<AsyncValue<NutritionTotals>>((ref) {
  return ref.watch(todayLogEntriesProvider).whenData(NutritionStats.totalsFor);
});

final StreamProvider<NutritionGoal?> nutritionGoalProvider = StreamProvider<NutritionGoal?>((ref) {
  return ref.watch(nutritionRepositoryProvider).watchGoal();
});
