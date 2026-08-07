import '../../../../core/utils/result.dart';
import '../repositories/goal_repository.dart';

class ToggleMilestone {
  ToggleMilestone(this._repository);

  final GoalRepository _repository;

  Future<Result<void>> call(String id) => _repository.toggleMilestone(id);
}
