import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/nutrition_goal.dart';
import '../repositories/nutrition_repository.dart';

class UpdateNutritionGoal {
  UpdateNutritionGoal(this._repository);

  final NutritionRepository _repository;

  Future<Result<void>> call(NutritionGoal goal) async {
    if (goal.dailyCalories <= 0) {
      return const Result.err(ValidationFailure('Daily calorie target must be greater than zero.'));
    }
    return _repository.updateGoal(goal);
  }
}
