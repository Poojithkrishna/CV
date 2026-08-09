import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/supplement.dart';
import '../repositories/supplement_repository.dart';

class CreateSupplement {
  CreateSupplement(this._repository);

  final SupplementRepository _repository;

  Future<Result<Supplement>> call(Supplement supplement) async {
    final Failure? error = validate(supplement);
    if (error != null) return Result.err(error);
    return _repository.createSupplement(supplement);
  }

  static Failure? validate(Supplement supplement) {
    if (supplement.name.trim().isEmpty) {
      return const ValidationFailure('Supplement name is required.');
    }
    return null;
  }
}
