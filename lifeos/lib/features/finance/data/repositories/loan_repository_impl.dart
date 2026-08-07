import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../domain/repositories/loan_repository.dart';
import '../daos/loans_dao.dart';
import 'loan_mapper.dart';

class LoanRepositoryImpl implements LoanRepository {
  LoanRepositoryImpl(this._dao);

  final LoansDao _dao;

  @override
  Stream<List<Loan>> watchActiveLoans() {
    return _dao
        .watchActiveLoans()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Loan?> watchLoan(String id) {
    return _dao.watchLoan(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Loan>> createLoan(Loan loan) async {
    try {
      await _dao.insertLoan(loan.toCompanion());
      return Result.ok(loan);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save loan: $e'));
    }
  }

  @override
  Future<Result<Loan>> updateLoan(Loan loan) async {
    try {
      final bool updated = await _dao.updateLoan(loan.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Loan no longer exists.'));
      }
      return Result.ok(loan);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update loan: $e'));
    }
  }

  @override
  Future<Result<void>> deleteLoan(String id) async {
    try {
      await _dao.deleteLoan(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete loan: $e'));
    }
  }

  @override
  Stream<List<LoanPayment>> watchPaymentsForLoan(String loanId) {
    return _dao
        .watchPaymentsForLoan(loanId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> recordPayment(LoanPayment payment) async {
    try {
      await _dao.recordPayment(payment.toCompanion());
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not record payment: $e'));
    }
  }

  @override
  Future<Result<void>> deletePayment(String id) async {
    try {
      await _dao.deletePayment(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete payment: $e'));
    }
  }
}
