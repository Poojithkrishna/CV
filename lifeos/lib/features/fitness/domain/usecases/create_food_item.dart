import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/food_item.dart';
import '../repositories/nutrition_repository.dart';

class CreateFoodItem {
  CreateFoodItem(this._repository);

  final NutritionRepository _repository;

  Future<Result<FoodItem>> call(FoodItem item) async {
    final Failure? error = validate(item);
    if (error != null) return Result.err(error);
    return _repository.createFoodItem(item);
  }

  static Failure? validate(FoodItem item) {
    if (item.name.trim().isEmpty) {
      return const ValidationFailure('Food name is required.');
    }
    if (item.caloriesPerServing < 0 || item.proteinG < 0 || item.carbsG < 0 || item.fatG < 0) {
      return const ValidationFailure('Nutrition values cannot be negative.');
    }
    return null;
  }
}
