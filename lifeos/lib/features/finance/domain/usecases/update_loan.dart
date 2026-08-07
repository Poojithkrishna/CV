import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';
import 'create_loan.dart';

class UpdateLoan {
  UpdateLoan(this._repository);

  final LoanRepository _repository;

  Future<Result<Loan>> call(Loan loan) async {
    final Failure? error = CreateLoan.validate(loan);
    if (error != null) return Result.err(error);
    return _repository.updateLoan(loan.copyWith(updatedAt: DateTime.now()));
  }
}
