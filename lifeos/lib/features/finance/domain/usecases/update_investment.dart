import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/investment.dart';
import '../repositories/investment_repository.dart';
import 'create_investment.dart';

class UpdateInvestment {
  UpdateInvestment(this._repository);

  final InvestmentRepository _repository;

  Future<Result<Investment>> call(Investment investment) async {
    final Failure? error = CreateInvestment.validate(investment);
    if (error != null) return Result.err(error);
    return _repository.updateInvestment(investment.copyWith(updatedAt: DateTime.now()));
  }
}
