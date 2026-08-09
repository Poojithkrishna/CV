import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/cardio_session.dart';
import '../repositories/cardio_session_repository.dart';

class LogCardioSession {
  LogCardioSession(this._repository);

  final CardioSessionRepository _repository;

  Future<Result<CardioSession>> call(CardioSession session) async {
    final Failure? error = validate(session);
    if (error != null) return Result.err(error);
    return _repository.logSession(session);
  }

  static Failure? validate(CardioSession session) {
    if (session.durationMinutes <= 0) {
      return const ValidationFailure('Duration must be greater than zero.');
    }
    if (session.distanceKm != null && session.distanceKm! < 0) {
      return const ValidationFailure('Distance cannot be negative.');
    }
    if (session.caloriesBurned != null && session.caloriesBurned! < 0) {
      return const ValidationFailure('Calories cannot be negative.');
    }
    return null;
  }
}
