import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/loans_dao.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../domain/usecases/create_loan.dart';
import '../../domain/usecases/delete_loan.dart';
import '../../domain/usecases/delete_loan_payment.dart';
import '../../domain/usecases/record_loan_payment.dart';
import '../../domain/usecases/update_loan.dart';

final Provider<LoansDao> loansDaoProvider = Provider<LoansDao>((ref) {
  return LoansDao(ref.watch(appDatabaseProvider));
});

final Provider<LoanRepository> loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl(ref.watch(loansDaoProvider));
});

final Provider<CreateLoan> createLoanUseCaseProvider = Provider(
  (ref) => CreateLoan(ref.watch(loanRepositoryProvider)),
);

final Provider<UpdateLoan> updateLoanUseCaseProvider = Provider(
  (ref) => UpdateLoan(ref.watch(loanRepositoryProvider)),
);

final Provider<DeleteLoan> deleteLoanUseCaseProvider = Provider(
  (ref) => DeleteLoan(ref.watch(loanRepositoryProvider)),
);

final Provider<RecordLoanPayment> recordLoanPaymentUseCaseProvider = Provider(
  (ref) => RecordLoanPayment(ref.watch(loanRepositoryProvider)),
);

final Provider<DeleteLoanPayment> deleteLoanPaymentUseCaseProvider = Provider(
  (ref) => DeleteLoanPayment(ref.watch(loanRepositoryProvider)),
);

final StreamProvider<List<Loan>> activeLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(loanRepositoryProvider).watchActiveLoans();
});

final StreamProviderFamily<Loan?, String> loanByIdProvider =
    StreamProvider.family<Loan?, String>((ref, id) {
  return ref.watch(loanRepositoryProvider).watchLoan(id);
});

final StreamProviderFamily<List<LoanPayment>, String> paymentsForLoanProvider =
    StreamProvider.family<List<LoanPayment>, String>((ref, loanId) {
  return ref.watch(loanRepositoryProvider).watchPaymentsForLoan(loanId);
});
