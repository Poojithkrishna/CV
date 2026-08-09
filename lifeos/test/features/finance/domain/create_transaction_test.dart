import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_entry.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_type.dart';
import 'package:lifeos/features/finance/domain/repositories/transaction_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_transaction.dart';

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
  Stream<List<TransactionEntry>> watchTransactionsBetween(DateTime from, DateTime to) =>
      const Stream.empty();

  @override
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 20}) =>
      const Stream.empty();
}

TransactionEntry _buildEntry({
  TransactionType type = TransactionType.expense,
  double amount = 100,
  String accountId = 'acc-a',
  String? transferAccountId,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return TransactionEntry(
    id: 'txn-1',
    accountId: accountId,
    type: type,
    amount: amount,
    date: now,
    transferAccountId: transferAccountId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateTransaction', () {
    test('persists a valid expense', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry());

      expect(result.isOk, isTrue);
      expect(repo.saved?.amount, 100);
    });

    test('rejects a zero or negative amount', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry(amount: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a transfer with no destination account', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry(type: TransactionType.transfer));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a transfer to the same account', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry(
        type: TransactionType.transfer,
        accountId: 'acc-a',
        transferAccountId: 'acc-a',
      ));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a non-transfer that carries a destination account', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry(
        type: TransactionType.expense,
        transferAccountId: 'acc-b',
      ));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('accepts a valid transfer', () async {
      final repo = _FakeTransactionRepository();
      final useCase = CreateTransaction(repo);

      final result = await useCase(_buildEntry(
        type: TransactionType.transfer,
        accountId: 'acc-a',
        transferAccountId: 'acc-b',
      ));

      expect(result.isOk, isTrue);
      expect(repo.saved?.transferAccountId, 'acc-b');
    });
  });
}
