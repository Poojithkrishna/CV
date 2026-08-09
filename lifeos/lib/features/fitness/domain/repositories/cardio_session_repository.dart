import '../../../../core/utils/result.dart';
import '../entities/cardio_session.dart';

abstract interface class CardioSessionRepository {
  Stream<List<CardioSession>> watchAllSessions();
  Stream<CardioSession?> watchSession(String id);

  Future<Result<CardioSession>> logSession(CardioSession session);
  Future<Result<CardioSession>> updateSession(CardioSession session);
  Future<Result<void>> deleteSession(String id);
}
