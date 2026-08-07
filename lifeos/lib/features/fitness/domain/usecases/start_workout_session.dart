import '../../../../core/utils/result.dart';
import '../entities/workout_session.dart';
import '../repositories/workout_session_repository.dart';

class StartWorkoutSession {
  StartWorkoutSession(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Result<WorkoutSession>> call(WorkoutSession session) {
    return _repository.startSession(session);
  }
}
