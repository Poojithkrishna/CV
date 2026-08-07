import '../../../../core/utils/result.dart';
import '../repositories/workout_session_repository.dart';

class DeleteLoggedSet {
  DeleteLoggedSet(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteLoggedSet(id);
}
