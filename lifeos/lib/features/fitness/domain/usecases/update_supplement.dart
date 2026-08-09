import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/supplement.dart';
import '../repositories/supplement_repository.dart';
import 'create_supplement.dart';

class UpdateSupplement {
  UpdateSupplement(this._repository);

  final SupplementRepository _repository;

  Future<Result<Supplement>> call(Supplement supplement) async {
    final Failure? error = CreateSupplement.validate(supplement);
    if (error != null) return Result.err(error);
    return _repository.updateSupplement(supplement.copyWith(updatedAt: DateTime.now()));
  }
}
