import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/loan_payments_table.dart';
import '../tables/loans_table.dart';

part 'loans_dao.g.dart';

/// Owns both Loans and LoanPayments because recording or deleting a
/// payment has to update `remainingAmount` atomically with the payment
/// row itself.
@DriftAccessor(tables: [Loans, LoanPayments])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  Stream<List<LoanRow>> watchActiveLoans() {
    return (select(loans)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  Stream<LoanRow?> watchLoan(String id) {
    return (select(loans)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<LoanRow?> getLoan(String id) {
    return (select(loans)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertLoan(LoansCompanion entry) {
    return into(loans).insert(entry);
  }

  Future<bool> updateLoan(LoansCompanion entry) {
    return update(loans).replace(entry);
  }

  Future<int> deleteLoan(String id) {
    return (delete(loans)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<List<LoanPaymentRow>> watchPaymentsForLoan(String loanId) {
    return (select(loanPayments)
          ..where((tbl) => tbl.loanId.equals(loanId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  /// Inserts a payment and reduces the loan's remaining amount by the
  /// same amount, atomically.
  Future<void> recordPayment(LoanPaymentsCompanion payment) {
    return transaction(() async {
      await into(loanPayments).insert(payment);
      await _adjustRemaining(payment.loanId.value, -payment.amount.value);
    });
  }

  /// Deletes a payment and restores that amount back onto the loan's
  /// remaining balance, atomically.
  Future<void> deletePayment(String id) {
    return transaction(() async {
      final LoanPaymentRow? payment =
          await (select(loanPayments)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (payment == null) return;
      await (delete(loanPayments)..where((tbl) => tbl.id.equals(id))).go();
      await _adjustRemaining(payment.loanId, payment.amount);
    });
  }

  Future<void> _adjustRemaining(String loanId, double delta) async {
    await (update(loans)..where((tbl) => tbl.id.equals(loanId))).write(
      LoansCompanion.custom(
        remainingAmount: loans.remainingAmount + Variable(delta),
        updatedAt: Variable(DateTime.now()),
      ),
    );
  }
}
