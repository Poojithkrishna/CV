import '../../../../core/utils/result.dart';
import '../entities/loan.dart';
import '../entities/loan_payment.dart';

abstract interface class LoanRepository {
  Stream<List<Loan>> watchActiveLoans();
  Stream<Loan?> watchLoan(String id);

  Future<Result<Loan>> createLoan(Loan loan);
  Future<Result<Loan>> updateLoan(Loan loan);
  Future<Result<void>> deleteLoan(String id);

  Stream<List<LoanPayment>> watchPaymentsForLoan(String loanId);
  Future<Result<void>> recordPayment(LoanPayment payment);
  Future<Result<void>> deletePayment(String id);
}
