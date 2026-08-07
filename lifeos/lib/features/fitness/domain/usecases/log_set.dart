import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/logged_set.dart';
import '../repositories/workout_session_repository.dart';

class LogSet {
  LogSet(this._repository);

  final WorkoutSessionRepository _repository;

  Future<Result<LoggedSet>> call(LoggedSet loggedSet) async {
    if (loggedSet.reps <= 0) {
      return const Result.err(ValidationFailure('Reps must be at least 1.'));
    }
    if (loggedSet.weight < 0) {
      return const Result.err(ValidationFailure('Weight cannot be negative.'));
    }
    return _repository.logSet(loggedSet);
  }
}
