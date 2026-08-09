import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/food_log_entry.dart';
import '../repositories/nutrition_repository.dart';

class LogFood {
  LogFood(this._repository);

  final NutritionRepository _repository;

  Future<Result<void>> call(FoodLogEntry entry) async {
    if (entry.servings <= 0) {
      return const Result.err(ValidationFailure('Servings must be greater than zero.'));
    }
    return _repository.logFood(entry);
  }
}
