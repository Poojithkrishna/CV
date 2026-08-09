import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cardio_session.dart';
import '../../domain/repositories/cardio_session_repository.dart';
import '../daos/cardio_sessions_dao.dart';
import 'cardio_session_mapper.dart';

class CardioSessionRepositoryImpl implements CardioSessionRepository {
  CardioSessionRepositoryImpl(this._dao);

  final CardioSessionsDao _dao;

  @override
  Stream<List<CardioSession>> watchAllSessions() {
    return _dao
        .watchAllSessions()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<CardioSession?> watchSession(String id) {
    return _dao.watchSession(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<CardioSession>> logSession(CardioSession session) async {
    try {
      await _dao.insertSession(session.toCompanion());
      return Result.ok(session);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save cardio session: $e'));
    }
  }

  @override
  Future<Result<CardioSession>> updateSession(CardioSession session) async {
    try {
      final bool updated = await _dao.updateSession(session.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Cardio session no longer exists.'));
      }
      return Result.ok(session);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update cardio session: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSession(String id) async {
    try {
      await _dao.deleteSession(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete cardio session: $e'));
    }
  }
}
