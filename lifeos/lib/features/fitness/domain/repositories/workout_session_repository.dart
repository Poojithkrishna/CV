import '../../../../core/utils/result.dart';
import '../entities/logged_set.dart';
import '../entities/workout_session.dart';

abstract interface class WorkoutSessionRepository {
  Stream<List<WorkoutSession>> watchRecentSessions({int limit});
  Stream<WorkoutSession?> watchSession(String id);
  Stream<WorkoutSession?> watchInProgressSession();

  Future<Result<WorkoutSession>> startSession(WorkoutSession session);
  Future<Result<WorkoutSession>> endSession(WorkoutSession session);
  Future<Result<void>> deleteSession(String id);

  Stream<List<LoggedSet>> watchSetsForSession(String sessionId);
  Future<List<LoggedSet>> getRecentSetsForExercise(String exerciseId, {int limit});
  Future<double?> getMaxWeightForExercise(String exerciseId);

  /// Returns the logged set with its `isPr` flag set to whatever the DAO
  /// actually computed — never trust the flag on the input.
  Future<Result<LoggedSet>> logSet(LoggedSet loggedSet);
  Future<Result<void>> deleteLoggedSet(String id);
}
