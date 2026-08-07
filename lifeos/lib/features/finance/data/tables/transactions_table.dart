import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// SQLite schema for a single income/expense/transfer entry. A transfer
/// uses [accountId] as the source and [transferAccountId] as the
/// destination; [categoryId] stays null for transfers since money moving
/// between your own accounts isn't spend or income.
///
/// Both account foreign keys cascade on delete: a transaction (or one leg
/// of a transfer) that references a deleted account no longer means
/// anything on its own, so it's removed along with the account rather
/// than left dangling.
@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();

  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();

  TextColumn get categoryId =>
      text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();

  /// Stored as [TransactionType.name] (`"income"` / `"expense"` / `"transfer"`).
  TextColumn get type => text()();

  /// Always stored positive; [type] determines the sign applied to the
  /// affected account balance(s).
  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  /// Destination account for a transfer; null for income/expense.
  TextColumn get transferAccountId =>
      text().nullable().references(Accounts, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
