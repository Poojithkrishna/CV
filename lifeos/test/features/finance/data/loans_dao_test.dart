import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/loan_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/loan.dart';
import 'package:lifeos/features/finance/domain/entities/loan_direction.dart';
import 'package:lifeos/features/finance/domain/entities/loan_payment.dart';

Loan _buildLoan(String id, {double principal = 5000}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Loan(
    id: id,
    direction: LoanDirection.given,
    personName: 'Alex',
    principalAmount: principal,
    remainingAmount: principal,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.loansDao.insertLoan(_buildLoan('l1').toCompanion());
  });

  tearDown(() async {
    await database.close();
  });

  Future<double> remainingOf(String id) async {
    final row = await database.loansDao.getLoan(id);
    return row!.remainingAmount;
  }

  test('recording a payment reduces the remaining amount and inserts a payment row', () async {
    final DateTime now = DateTime(2026, 1, 5);
    final LoanPayment payment = LoanPayment(
      id: 'p1',
      loanId: 'l1',
      amount: 1500,
      date: now,
      createdAt: now,
    );
    await database.loansDao.recordPayment(payment.toCompanion());

    expect(await remainingOf('l1'), 3500);
    final payments = await database.loansDao.watchPaymentsForLoan('l1').first;
    expect(payments, hasLength(1));
    expect(payments.single.amount, 1500);
  });

  test('deleting a payment restores the remaining amount and removes the row', () async {
    final DateTime now = DateTime(2026, 1, 5);
    final LoanPayment payment = LoanPayment(
      id: 'p1',
      loanId: 'l1',
      amount: 2000,
      date: now,
      createdAt: now,
    );
    await database.loansDao.recordPayment(payment.toCompanion());
    expect(await remainingOf('l1'), 3000);

    await database.loansDao.deletePayment('p1');
    expect(await remainingOf('l1'), 5000);
    expect(await database.loansDao.watchPaymentsForLoan('l1').first, isEmpty);
  });

  test('multiple partial payments accumulate correctly', () async {
    final DateTime now = DateTime(2026, 1, 5);
    await database.loansDao.recordPayment(
      LoanPayment(id: 'p1', loanId: 'l1', amount: 1000, date: now, createdAt: now).toCompanion(),
    );
    await database.loansDao.recordPayment(
      LoanPayment(id: 'p2', loanId: 'l1', amount: 2000, date: now, createdAt: now).toCompanion(),
    );

    expect(await remainingOf('l1'), 2000);
    expect(await database.loansDao.watchPaymentsForLoan('l1').first, hasLength(2));
  });
}
