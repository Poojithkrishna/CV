import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../repositories/loan_repository.dart';

class CreateLoan {
  CreateLoan(this._repository);

  final LoanRepository _repository;

  Future<Result<Loan>> call(Loan loan) async {
    final Failure? error = validate(loan);
    if (error != null) return Result.err(error);
    return _repository.createLoan(loan);
  }

  static Failure? validate(Loan loan) {
    if (loan.personName.trim().isEmpty) {
      return const ValidationFailure('Person\'s name is required.');
    }
    if (loan.principalAmount <= 0) {
      return const ValidationFailure('Amount must be greater than zero.');
    }
    if (loan.remainingAmount < 0 || loan.remainingAmount > loan.principalAmount) {
      return const ValidationFailure('Remaining amount must be between 0 and the loan amount.');
    }
    return null;
  }
}
