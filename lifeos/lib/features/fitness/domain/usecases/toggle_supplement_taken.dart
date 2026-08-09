import '../../../../core/utils/result.dart';
import '../repositories/supplement_repository.dart';

class ToggleSupplementTaken {
  ToggleSupplementTaken(this._repository);

  final SupplementRepository _repository;

  Future<Result<void>> call(String supplementId, DateTime date) =>
      _repository.toggleTaken(supplementId, date);
}
