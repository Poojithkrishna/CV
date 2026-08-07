import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/recurrence_frequency.dart';
import 'package:lifeos/features/finance/domain/entities/recurring_payment.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_entry.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_type.dart';
import 'package:lifeos/features/finance/domain/repositories/recurring_payment_repository.dart';
import 'package:lifeos/features/finance/domain/repositories/transaction_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_transaction.dart';
import 'package:lifeos/features/finance/domain/usecases/mark_recurring_payment_paid.dart';

class _FakeTransactionRepository implements TransactionRepository {
  TransactionEntry? saved;

  @override
  Future<Result<TransactionEntry>> createTransaction(TransactionEntry entry) async {
    saved = entry;
    return Result.ok(entry);
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async => const Result.ok(null);

  @override
  Future<Result<TransactionEntry>> updateTransaction(TransactionEntry entry) async =>
      Result.ok(entry);

  @override
  Stream<TransactionEntry?> watchTransaction(String id) => const Stream.empty();

  @override
  Stream<List<TransactionEntry>> watchTransactionsForAccount(String accountId) =>
      const Stream.empty();

  @override
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 20}) =>
      const Stream.empty();
}

class _FakeRecurringPaymentRepository implements RecurringPaymentRepository {
  RecurringPayment? updated;

  @override
  Future<Result<RecurringPayment>> createPayment(RecurringPayment payment) async =>
      Result.ok(payment);

  @override
  Future<Result<void>> deletePayment(String id) async => const Result.ok(null);

  @override
  Future<Result<RecurringPayment>> updatePayment(RecurringPayment payment) async {
    updated = payment;
    return Result.ok(payment);
  }

  @override
  Stream<RecurringPayment?> watchPayment(String id) => const Stream.empty();

  @override
  Stream<List<RecurringPayment>> watchActivePayments() => const Stream.empty();
}

RecurringPayment _buildPayment({String? accountId, double amount = 500}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecurringPayment(
    id: 'bill-1',
    name: 'Netflix',
    amount: amount,
    frequency: RecurrenceFrequency.monthly,
    nextDueDate: DateTime(2026, 1, 15),
    colorValue: 0xFF7C4DFF,
    accountId: accountId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('MarkRecurringPaymentPaid', () {
    test('logs an expense transaction and advances the due date when an account is linked',
        () async {
      final txnRepo = _FakeTransactionRepository();
      final billRepo = _FakeRecurringPaymentRepository();
      final useCase = MarkRecurringPaymentPaid(billRepo, CreateTransaction(txnRepo));

      final result = await useCase(_buildPayment(accountId: 'acc-1'));

      expect(result.isOk, isTrue);
      expect(txnRepo.saved?.type, TransactionType.expense);
      expect(txnRepo.saved?.accountId, 'acc-1');
      expect(txnRepo.saved?.amount, 500);
      expect(billRepo.updated?.nextDueDate, DateTime(2026, 2, 15));
    });

    test('uses the overridden actual amount for the transaction, not the expected amount',
        () async {
      final txnRepo = _FakeTransactionRepository();
      final billRepo = _FakeRecurringPaymentRepository();
      final useCase = MarkRecurringPaymentPaid(billRepo, CreateTransaction(txnRepo));

      await useCase(_buildPayment(accountId: 'acc-1', amount: 500), actualAmount: 650);

      expect(txnRepo.saved?.amount, 650);
    });

    test('just advances the schedule, without logging a transaction, when no account is linked',
        () async {
      final txnRepo = _FakeTransactionRepository();
      final billRepo = _FakeRecurringPaymentRepository();
      final useCase = MarkRecurringPaymentPaid(billRepo, CreateTransaction(txnRepo));

      final result = await useCase(_buildPayment(accountId: null));

      expect(result.isOk, isTrue);
      expect(txnRepo.saved, isNull);
      expect(billRepo.updated?.nextDueDate, DateTime(2026, 2, 15));
    });

    test('rejects a zero or negative overridden amount', () async {
      final txnRepo = _FakeTransactionRepository();
      final billRepo = _FakeRecurringPaymentRepository();
      final useCase = MarkRecurringPaymentPaid(billRepo, CreateTransaction(txnRepo));

      final result =
          await useCase(_buildPayment(accountId: 'acc-1'), actualAmount: 0);

      expect(result.isErr, isTrue);
      expect(txnRepo.saved, isNull);
      expect(billRepo.updated, isNull);
    });
  });
}
