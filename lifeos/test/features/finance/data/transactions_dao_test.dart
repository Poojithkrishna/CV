import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/account_mapper.dart';
import 'package:lifeos/features/finance/data/repositories/transaction_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/account.dart';
import 'package:lifeos/features/finance/domain/entities/account_type.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_entry.dart';
import 'package:lifeos/features/finance/domain/entities/transaction_type.dart';

Account _buildAccount(String id, {double balance = 1000}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Account(
    id: id,
    name: 'Account $id',
    type: AccountType.bank,
    currentBalance: balance,
    openingBalance: balance,
    colorValue: 0xFF22C55E,
    createdAt: now,
    updatedAt: now,
  );
}

TransactionEntry _buildEntry({
  required String id,
  required String accountId,
  required TransactionType type,
  required double amount,
  String? transferAccountId,
}) {
  final DateTime now = DateTime(2026, 1, 2);
  return TransactionEntry(
    id: id,
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
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.accountsDao.insertAccount(_buildAccount('a').toCompanion());
    await database.accountsDao.insertAccount(_buildAccount('b').toCompanion());
  });

  tearDown(() async {
    await database.close();
  });

  Future<double> balanceOf(String id) async {
    final row = await database.accountsDao.getAccount(id);
    return row!.currentBalance;
  }

  test('income increases the account balance', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.income,
      amount: 500,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());

    expect(await balanceOf('a'), 1500);
  });

  test('expense decreases the account balance', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.expense,
      amount: 200,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());

    expect(await balanceOf('a'), 800);
  });

  test('transfer moves money from the source to the destination account', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.transfer,
      amount: 300,
      transferAccountId: 'b',
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());

    expect(await balanceOf('a'), 700);
    expect(await balanceOf('b'), 1300);
  });

  test('deleting a transaction reverts its effect', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.expense,
      amount: 200,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());
    expect(await balanceOf('a'), 800);

    await database.transactionsDao.deleteTransaction('t1');
    expect(await balanceOf('a'), 1000);
  });

  test('updating the amount reverts the old effect and applies the new one', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.expense,
      amount: 200,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());
    expect(await balanceOf('a'), 800);

    final TransactionEntry updated = entry.copyWith(amount: 350);
    await database.transactionsDao.updateTransaction(updated.toCompanion());

    expect(await balanceOf('a'), 650);
  });

  test('reassigning a transaction to a different account moves the effect', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.expense,
      amount: 200,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());
    expect(await balanceOf('a'), 800);
    expect(await balanceOf('b'), 1000);

    final TransactionEntry reassigned = entry.copyWith(accountId: 'b');
    await database.transactionsDao.updateTransaction(reassigned.toCompanion());

    expect(await balanceOf('a'), 1000);
    expect(await balanceOf('b'), 800);
  });

  test('changing a transaction from expense to transfer applies transfer semantics', () async {
    final TransactionEntry entry = _buildEntry(
      id: 't1',
      accountId: 'a',
      type: TransactionType.expense,
      amount: 200,
    );
    await database.transactionsDao.createTransaction(entry.toCompanion());
    expect(await balanceOf('a'), 800);

    final TransactionEntry asTransfer = entry.copyWith(
      type: TransactionType.transfer,
      transferAccountId: 'b',
    );
    await database.transactionsDao.updateTransaction(asTransfer.toCompanion());

    // Expense reverted (+200 back to 1000), then transfer applied (-200 / +200).
    expect(await balanceOf('a'), 800);
    expect(await balanceOf('b'), 1200);
  });
}
