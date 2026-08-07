import '../../../../core/utils/result.dart';
import '../repositories/loan_repository.dart';

class DeleteLoanPayment {
  DeleteLoanPayment(this._repository);

  final LoanRepository _repository;

  Future<Result<void>> call(String id) => _repository.deletePayment(id);
}
