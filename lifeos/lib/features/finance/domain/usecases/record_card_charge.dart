import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../repositories/credit_card_repository.dart';

/// Records a new charge/purchase on a card, increasing its usage.
class RecordCardCharge {
  RecordCardCharge(this._repository);

  final CreditCardRepository _repository;

  Future<Result<void>> call(String cardId, double amount) async {
    if (amount <= 0) {
      return const Result.err(ValidationFailure('Amount must be greater than zero.'));
    }
    return _repository.adjustUsage(cardId, amount);
  }
}
