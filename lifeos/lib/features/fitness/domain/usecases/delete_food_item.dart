import '../../../../core/utils/result.dart';
import '../repositories/nutrition_repository.dart';

class DeleteFoodItem {
  DeleteFoodItem(this._repository);

  final NutritionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteFoodItem(id);
}
