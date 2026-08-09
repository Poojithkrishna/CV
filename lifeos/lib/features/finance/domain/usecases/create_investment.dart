import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/investment.dart';
import '../repositories/investment_repository.dart';

class CreateInvestment {
  CreateInvestment(this._repository);

  final InvestmentRepository _repository;

  Future<Result<Investment>> call(Investment investment) async {
    final Failure? error = validate(investment);
    if (error != null) return Result.err(error);
    return _repository.createInvestment(investment);
  }

  static Failure? validate(Investment investment) {
    if (investment.name.trim().isEmpty) {
      return const ValidationFailure('Investment name is required.');
    }
    if (investment.investedAmount < 0 || investment.currentValue < 0) {
      return const ValidationFailure('Amounts cannot be negative.');
    }
    return null;
  }
}
