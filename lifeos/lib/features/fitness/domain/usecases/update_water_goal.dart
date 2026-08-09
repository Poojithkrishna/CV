import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/water_repository.dart';

class UpdateWaterGoal {
  UpdateWaterGoal(this._repository);

  final WaterRepository _repository;

  Future<Result<void>> call(int dailyGoalMl) async {
    if (dailyGoalMl <= 0) {
      return const Result.err(ValidationFailure('Daily goal must be greater than zero.'));
    }
    return _repository.updateGoal(dailyGoalMl);
  }
}
