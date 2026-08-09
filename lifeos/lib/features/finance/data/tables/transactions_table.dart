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

  // See milestones_table.dart in the goals feature for why these use
  // .customConstraint() instead of .references() — the latter's
  // generated constraint was silently dropped by drift_dev in this
  // schema.
  TextColumn get accountId =>
      text().customConstraint('NOT NULL REFERENCES accounts (id) ON DELETE CASCADE')();

  TextColumn get categoryId =>
      text().customConstraint('REFERENCES categories (id) ON DELETE SET NULL')();

  /// Stored as [TransactionType.name] (`"income"` / `"expense"` / `"transfer"`).
  TextColumn get type => text()();

  /// Always stored positive; [type] determines the sign applied to the
  /// affected account balance(s).
  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();

  /// Destination account for a transfer; null for income/expense.
  TextColumn get transferAccountId =>
      text().customConstraint('REFERENCES accounts (id) ON DELETE CASCADE')();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
