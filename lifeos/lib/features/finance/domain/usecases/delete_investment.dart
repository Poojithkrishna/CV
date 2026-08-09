import '../../../../core/utils/result.dart';
import '../repositories/investment_repository.dart';

class DeleteInvestment {
  DeleteInvestment(this._repository);

  final InvestmentRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteInvestment(id);
}
