import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../entities/loan_payment.dart';
import '../repositories/loan_repository.dart';

class RecordLoanPayment {
  RecordLoanPayment(this._repository);

  final LoanRepository _repository;

  /// [loan] is the payment's target loan, passed in so this can validate
  /// against its current remaining amount without a second database read.
  Future<Result<void>> call(Loan loan, LoanPayment payment) async {
    if (payment.amount <= 0) {
      return const Result.err(ValidationFailure('Amount must be greater than zero.'));
    }
    if (payment.amount > loan.remainingAmount) {
      return const Result.err(ValidationFailure('Amount cannot exceed what remains on the loan.'));
    }
    return _repository.recordPayment(payment);
  }
}
