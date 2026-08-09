import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_log_entry.dart';
import '../../domain/entities/nutrition_goal.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../daos/nutrition_dao.dart';
import 'food_item_mapper.dart';
import 'food_log_entry_mapper.dart';
import 'nutrition_goal_mapper.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  NutritionRepositoryImpl(this._dao);

  final NutritionDao _dao;

  @override
  Stream<List<FoodItem>> watchActiveFoodItems() {
    return _dao
        .watchActiveFoodItems()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<FoodItem?> watchFoodItem(String id) {
    return _dao.watchFoodItem(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<FoodItem>> createFoodItem(FoodItem item) async {
    try {
      await _dao.insertFoodItem(item.toCompanion());
      return Result.ok(item);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save food item: $e'));
    }
  }

  @override
  Future<Result<FoodItem>> updateFoodItem(FoodItem item) async {
    try {
      final bool updated = await _dao.updateFoodItem(item.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Food item no longer exists.'));
      }
      return Result.ok(item);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update food item: $e'));
    }
  }

  @override
  Future<Result<void>> deleteFoodItem(String id) async {
    try {
      await _dao.deleteFoodItem(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete food item: $e'));
    }
  }

  @override
  Stream<List<FoodLogEntry>> watchLogEntriesForDate(DateTime date) {
    return _dao
        .watchLogEntriesForDate(date)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> logFood(FoodLogEntry entry) async {
    try {
      await _dao.insertLogEntry(entry.toCompanion());
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not log food: $e'));
    }
  }

  @override
  Future<Result<void>> deleteLogEntry(String id) async {
    try {
      await _dao.deleteLogEntry(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete log entry: $e'));
    }
  }

  @override
  Stream<NutritionGoal?> watchGoal() {
    return _dao.watchGoal().map((row) => row?.toDomain());
  }

  @override
  Future<Result<void>> updateGoal(NutritionGoal goal) async {
    try {
      await _dao.updateGoal(goal.toCompanion());
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update nutrition goal: $e'));
    }
  }
}
