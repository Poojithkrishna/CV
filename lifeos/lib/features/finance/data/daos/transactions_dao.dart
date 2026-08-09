import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

/// Owns both the Transactions and Accounts tables because every write
/// here has a side effect on one or two account balances, and that side
/// effect must be atomic with the transaction row itself — never leave a
/// transaction recorded without its balance effect applied, or vice
/// versa.
@DriftAccessor(tables: [Transactions, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Stream<List<TransactionRow>> watchRecentTransactions({int limit = 20}) {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  /// Every transaction (including transfers) with a date in `[from, to]`,
  /// oldest first — used for Analytics, which buckets by calendar month
  /// rather than needing a specific account.
  Stream<List<TransactionRow>> watchTransactionsBetween(DateTime from, DateTime to) {
    return (select(transactions)
          ..where((t) => t.date.isBiggerOrEqualValue(from) & t.date.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Stream<List<TransactionRow>> watchTransactionsForAccount(String accountId) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId) | t.transferAccountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<TransactionRow?> watchTransaction(String id) {
    return (select(transactions)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<TransactionRow?> getTransaction(String id) {
    return (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts [entry] and applies its effect on the linked account
  /// balance(s) in the same database transaction, so a crash or error
  /// between the two steps can never happen.
  Future<void> createTransaction(TransactionsCompanion entry) {
    return transaction(() async {
      await into(transactions).insert(entry);
      await _applyEffect(entry, sign: 1);
    });
  }

  /// Replaces the row matching [updated]'s id and re-applies its balance
  /// effect: reverts whatever the previous row did, then applies the new
  /// row's effect. This correctly handles the account, category, amount
  /// or type having changed between the old and new version.
  Future<void> updateTransaction(TransactionsCompanion updated) {
    return transaction(() async {
      final String id = updated.id.value;
      final TransactionRow? previous = await getTransaction(id);
      if (previous == null) {
        throw StateError('Transaction $id no longer exists.');
      }
      await _applyEffect(previous.toCompanion(true), sign: -1);
      await update(transactions).replace(updated);
      await _applyEffect(updated, sign: 1);
    });
  }

  /// Deletes the transaction and reverts its balance effect atomically.
  Future<void> deleteTransaction(String id) {
    return transaction(() async {
      final TransactionRow? row = await getTransaction(id);
      if (row == null) return;
      await _applyEffect(row.toCompanion(true), sign: -1);
      await (delete(transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Applies (`sign: 1`) or reverts (`sign: -1`) a transaction's effect on
  /// its account balance(s).
  Future<void> _applyEffect(TransactionsCompanion entry, {required int sign}) async {
    final double amount = entry.amount.value;
    final String type = entry.type.value;
    final String fromAccountId = entry.accountId.value;

    switch (type) {
      case 'income':
        await _adjustBalance(fromAccountId, amount * sign);
      case 'expense':
        await _adjustBalance(fromAccountId, -amount * sign);
      case 'transfer':
        final String? toAccountId = entry.transferAccountId.value;
        await _adjustBalance(fromAccountId, -amount * sign);
        if (toAccountId != null) {
          await _adjustBalance(toAccountId, amount * sign);
        }
      default:
        throw ArgumentError('Unknown transaction type: $type');
    }
  }

  /// `balance = balance + delta` as a single SQL expression update, so it
  /// composes safely with the other balance change inside the same
  /// transaction instead of racing a separate read.
  Future<void> _adjustBalance(String accountId, double delta) async {
    await (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion.custom(
        currentBalance: accounts.currentBalance + Variable(delta),
        updatedAt: Variable(DateTime.now()),
      ),
    );
  }
}
