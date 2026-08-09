import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../daos/workout_sessions_dao.dart';
import 'logged_set_mapper.dart';
import 'workout_session_mapper.dart';

class WorkoutSessionRepositoryImpl implements WorkoutSessionRepository {
  WorkoutSessionRepositoryImpl(this._dao);

  final WorkoutSessionsDao _dao;

  @override
  Stream<List<WorkoutSession>> watchRecentSessions({int limit = 20}) {
    return _dao
        .watchRecentSessions(limit: limit)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<WorkoutSession?> watchSession(String id) {
    return _dao.watchSession(id).map((row) => row?.toDomain());
  }

  @override
  Stream<WorkoutSession?> watchInProgressSession() {
    return _dao.watchInProgressSession().map((row) => row?.toDomain());
  }

  @override
  Stream<int> watchSessionCount() => _dao.watchSessionCount();

  @override
  Future<Result<WorkoutSession>> startSession(WorkoutSession session) async {
    try {
      await _dao.startSession(session.toCompanion());
      return Result.ok(session);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not start workout: $e'));
    }
  }

  @override
  Future<Result<WorkoutSession>> endSession(WorkoutSession session) async {
    try {
      final bool updated = await _dao.updateSession(session.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Session no longer exists.'));
      }
      return Result.ok(session);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not end workout: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      await _dao.deleteSession(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete workout: $e'));
    }
  }

  @override
  Stream<List<LoggedSet>> watchSetsForSession(String sessionId) {
    return _dao
        .watchSetsForSession(sessionId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<List<LoggedSet>> watchAllSetsForExercise(String exerciseId) {
    return _dao
        .watchAllSetsForExercise(exerciseId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<List<LoggedSet>> getRecentSetsForExercise(String exerciseId, {int limit = 10}) async {
    final rows = await _dao.getRecentSetsForExercise(exerciseId, limit: limit);
    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Future<double?> getMaxWeightForExercise(String exerciseId) {
    return _dao.getMaxWeightForExercise(exerciseId);
  }

  @override
  Future<Result<LoggedSet>> logSet(LoggedSet loggedSet) async {
    try {
      final bool isPr = await _dao.logSet(loggedSet.toCompanion());
      return Result.ok(loggedSet.copyWith(isPr: isPr));
    } catch (e) {
      return Result.err(DatabaseFailure('Could not log set: $e'));
    }
  }

  @override
  Future<Result<void>> deleteLoggedSet(String id) async {
    try {
      await _dao.deleteLoggedSet(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete set: $e'));
    }
  }
}
