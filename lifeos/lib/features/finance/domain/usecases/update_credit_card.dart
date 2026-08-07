import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/credit_card.dart';
import '../repositories/credit_card_repository.dart';
import 'create_credit_card.dart';

class UpdateCreditCard {
  UpdateCreditCard(this._repository);

  final CreditCardRepository _repository;

  Future<Result<CreditCard>> call(CreditCard card) async {
    final Failure? error = CreateCreditCard.validate(card);
    if (error != null) return Result.err(error);
    return _repository.updateCard(card.copyWith(updatedAt: DateTime.now()));
  }
}
