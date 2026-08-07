import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/loan.dart';
import 'package:lifeos/features/finance/domain/entities/loan_direction.dart';
import 'package:lifeos/features/finance/domain/entities/loan_payment.dart';
import 'package:lifeos/features/finance/domain/repositories/loan_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_loan.dart';
import 'package:lifeos/features/finance/domain/usecases/record_loan_payment.dart';

class _FakeLoanRepository implements LoanRepository {
  Loan? savedLoan;
  LoanPayment? savedPayment;

  @override
  Future<Result<Loan>> createLoan(Loan loan) async {
    savedLoan = loan;
    return Result.ok(loan);
  }

  @override
  Future<Result<void>> deleteLoan(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> deletePayment(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> recordPayment(LoanPayment payment) async {
    savedPayment = payment;
    return const Result.ok(null);
  }

  @override
  Future<Result<Loan>> updateLoan(Loan loan) async => Result.ok(loan);

  @override
  Stream<Loan?> watchLoan(String id) => const Stream.empty();

  @override
  Stream<List<Loan>> watchActiveLoans() => const Stream.empty();

  @override
  Stream<List<LoanPayment>> watchPaymentsForLoan(String loanId) => const Stream.empty();
}

Loan _buildLoan({double principal = 5000, double? remaining}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Loan(
    id: 'loan-1',
    direction: LoanDirection.given,
    personName: 'Sam',
    principalAmount: principal,
    remainingAmount: remaining ?? principal,
    createdAt: now,
    updatedAt: now,
  );
}

LoanPayment _buildPayment(double amount) {
  final DateTime now = DateTime(2026, 1, 2);
  return LoanPayment(id: 'pay-1', loanId: 'loan-1', amount: amount, date: now, createdAt: now);
}

void main() {
  group('CreateLoan', () {
    test('persists a valid loan', () async {
      final repo = _FakeLoanRepository();
      final useCase = CreateLoan(repo);

      final result = await useCase(_buildLoan());

      expect(result.isOk, isTrue);
      expect(repo.savedLoan?.personName, 'Sam');
    });

    test('rejects a blank person name', () async {
      final repo = _FakeLoanRepository();
      final useCase = CreateLoan(repo);

      final result = await useCase(_buildLoan().copyWith(personName: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedLoan, isNull);
    });

    test('rejects a zero amount', () async {
      final repo = _FakeLoanRepository();
      final useCase = CreateLoan(repo);

      final result = await useCase(_buildLoan(principal: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedLoan, isNull);
    });
  });

  group('RecordLoanPayment', () {
    test('records a valid partial payment', () async {
      final repo = _FakeLoanRepository();
      final useCase = RecordLoanPayment(repo);
      final loan = _buildLoan(principal: 5000);

      final result = await useCase(loan, _buildPayment(2000));

      expect(result.isOk, isTrue);
      expect(repo.savedPayment?.amount, 2000);
    });

    test('rejects a zero or negative amount', () async {
      final repo = _FakeLoanRepository();
      final useCase = RecordLoanPayment(repo);
      final loan = _buildLoan(principal: 5000);

      final result = await useCase(loan, _buildPayment(0));

      expect(result.isErr, isTrue);
      expect(repo.savedPayment, isNull);
    });

    test('rejects a payment larger than what remains', () async {
      final repo = _FakeLoanRepository();
      final useCase = RecordLoanPayment(repo);
      final loan = _buildLoan(principal: 5000, remaining: 1000);

      final result = await useCase(loan, _buildPayment(1500));

      expect(result.isErr, isTrue);
      expect(repo.savedPayment, isNull);
    });
  });
}
