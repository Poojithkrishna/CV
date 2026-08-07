import '../../../../core/utils/result.dart';
import '../repositories/loan_repository.dart';

class DeleteLoan {
  DeleteLoan(this._repository);

  final LoanRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteLoan(id);
}
