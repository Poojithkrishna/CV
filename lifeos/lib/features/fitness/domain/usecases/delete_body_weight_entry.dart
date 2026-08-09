import '../../../../core/utils/result.dart';
import '../repositories/body_weight_repository.dart';

class DeleteBodyWeightEntry {
  DeleteBodyWeightEntry(this._repository);

  final BodyWeightRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteEntry(id);
}
