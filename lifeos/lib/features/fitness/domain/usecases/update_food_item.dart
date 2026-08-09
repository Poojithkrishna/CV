import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/food_item.dart';
import '../repositories/nutrition_repository.dart';
import 'create_food_item.dart';

class UpdateFoodItem {
  UpdateFoodItem(this._repository);

  final NutritionRepository _repository;

  Future<Result<FoodItem>> call(FoodItem item) async {
    final Failure? error = CreateFoodItem.validate(item);
    if (error != null) return Result.err(error);
    return _repository.updateFoodItem(item.copyWith(updatedAt: DateTime.now()));
  }
}
