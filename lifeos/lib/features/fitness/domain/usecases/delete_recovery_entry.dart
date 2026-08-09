import '../../../../core/utils/result.dart';
import '../repositories/recovery_repository.dart';

class DeleteRecoveryEntry {
  DeleteRecoveryEntry(this._repository);

  final RecoveryRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteEntry(id);
}
