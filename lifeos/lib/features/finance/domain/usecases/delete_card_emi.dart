import '../../../../core/utils/result.dart';
import '../repositories/credit_card_repository.dart';

class DeleteCardEmi {
  DeleteCardEmi(this._repository);

  final CreditCardRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteEmi(id);
}
