import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/cardio_session.dart';
import '../repositories/cardio_session_repository.dart';
import 'log_cardio_session.dart';

class UpdateCardioSession {
  UpdateCardioSession(this._repository);

  final CardioSessionRepository _repository;

  Future<Result<CardioSession>> call(CardioSession session) async {
    final Failure? error = LogCardioSession.validate(session);
    if (error != null) return Result.err(error);
    return _repository.updateSession(session.copyWith(updatedAt: DateTime.now()));
  }
}
