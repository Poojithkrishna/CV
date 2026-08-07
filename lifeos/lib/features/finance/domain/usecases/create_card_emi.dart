import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/card_emi.dart';
import '../repositories/credit_card_repository.dart';

class CreateCardEmi {
  CreateCardEmi(this._repository);

  final CreditCardRepository _repository;

  Future<Result<CardEmi>> call(CardEmi emi) async {
    if (emi.description.trim().isEmpty) {
      return const Result.err(ValidationFailure('Description is required.'));
    }
    if (emi.totalAmount <= 0) {
      return const Result.err(ValidationFailure('Total amount must be greater than zero.'));
    }
    if (emi.monthlyAmount <= 0) {
      return const Result.err(ValidationFailure('Monthly amount must be greater than zero.'));
    }
    if (emi.tenureMonths <= 0) {
      return const Result.err(ValidationFailure('Tenure must be at least 1 month.'));
    }
    return _repository.createEmi(emi);
  }
}
