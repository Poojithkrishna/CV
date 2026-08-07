import '../../../../core/utils/result.dart';
import '../repositories/credit_card_repository.dart';

class DeleteCreditCard {
  DeleteCreditCard(this._repository);

  final CreditCardRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteCard(id);
}
