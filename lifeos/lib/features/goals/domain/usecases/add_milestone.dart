import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/milestone.dart';
import '../repositories/goal_repository.dart';

class AddMilestone {
  AddMilestone(this._repository);

  final GoalRepository _repository;

  Future<Result<Milestone>> call(Milestone milestone) async {
    if (milestone.title.trim().isEmpty) {
      return const Result.err(ValidationFailure('Milestone title is required.'));
    }
    return _repository.addMilestone(milestone);
  }
}
