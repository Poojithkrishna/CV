import '../../../../core/utils/result.dart';
import '../repositories/workout_session_repository.dart';

class DeleteWorkoutSession {
  DeleteWorkoutSession(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteSession(id);
}
