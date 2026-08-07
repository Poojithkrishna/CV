import '../../../../core/utils/result.dart';
import '../entities/workout_session.dart';
import '../repositories/workout_session_repository.dart';

class EndWorkoutSession {
  EndWorkoutSession(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Result<WorkoutSession>> call(WorkoutSession session) {
    final DateTime now = DateTime.now();
    return _repository.endSession(session.copyWith(endTime: now, updatedAt: now));
  }
}
