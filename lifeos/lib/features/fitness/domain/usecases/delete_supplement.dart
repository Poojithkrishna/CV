import '../../../../core/utils/result.dart';
import '../repositories/supplement_repository.dart';

class DeleteSupplement {
  DeleteSupplement(this._repository);

  final SupplementRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteSupplement(id);
}
