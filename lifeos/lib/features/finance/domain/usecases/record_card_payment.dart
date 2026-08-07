import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/credit_card_repository.dart';

/// Records a payment towards a card's balance, decreasing its usage.
/// Overpayment is allowed (usage can go negative, meaning the card issuer
/// owes you) rather than silently clamped, since that's a real state a
/// card can be in.
class RecordCardPayment {
  RecordCardPayment(this._repository);

  final CreditCardRepository _repository;

  Future<Result<void>> call(String cardId, double amount) async {
    if (amount <= 0) {
      return const Result.err(ValidationFailure('Amount must be greater than zero.'));
    }
    return _repository.adjustUsage(cardId, -amount);
  }
}
