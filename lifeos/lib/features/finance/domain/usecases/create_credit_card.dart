import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/credit_card.dart';
import '../repositories/credit_card_repository.dart';

class CreateCreditCard {
  CreateCreditCard(this._repository);

  final CreditCardRepository _repository;

  Future<Result<CreditCard>> call(CreditCard card) async {
    final Failure? error = validate(card);
    if (error != null) return Result.err(error);
    return _repository.createCard(card);
  }

  static Failure? validate(CreditCard card) {
    if (card.name.trim().isEmpty) {
      return const ValidationFailure('Card name is required.');
    }
    if (card.creditLimit <= 0) {
      return const ValidationFailure('Credit limit must be greater than zero.');
    }
    if (card.statementDay != null && (card.statementDay! < 1 || card.statementDay! > 31)) {
      return const ValidationFailure('Statement day must be between 1 and 31.');
    }
    if (card.dueDay != null && (card.dueDay! < 1 || card.dueDay! > 31)) {
      return const ValidationFailure('Due day must be between 1 and 31.');
    }
    if (card.annualFee != null && card.annualFee! < 0) {
      return const ValidationFailure('Annual fee cannot be negative.');
    }
    return null;
  }
}
