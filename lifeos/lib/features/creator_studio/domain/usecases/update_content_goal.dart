import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/content_studio_repository.dart';

class UpdateContentGoal {
  UpdateContentGoal(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<void>> call(int weeklyUploadTarget) async {
    if (weeklyUploadTarget <= 0) {
      return const Result.err(ValidationFailure('Weekly target must be greater than zero.'));
    }
    return _repository.updateGoal(weeklyUploadTarget);
  }
}
