import '../../../../core/utils/result.dart';
import '../repositories/cardio_session_repository.dart';

class DeleteCardioSession {
  DeleteCardioSession(this._repository);

  final CardioSessionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteSession(id);
}
