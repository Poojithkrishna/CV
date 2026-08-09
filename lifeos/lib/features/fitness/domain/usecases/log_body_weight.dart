import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/body_weight_entry.dart';
import '../repositories/body_weight_repository.dart';

class LogBodyWeight {
  LogBodyWeight(this._repository);

  final BodyWeightRepository _repository;

  Future<Result<BodyWeightEntry>> call(BodyWeightEntry entry) async {
    if (entry.weightKg <= 0) {
      return const Result.err(ValidationFailure('Weight must be greater than zero.'));
    }
    return _repository.logWeight(entry);
  }
}
