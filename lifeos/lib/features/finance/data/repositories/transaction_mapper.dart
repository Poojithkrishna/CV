import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/entities/transaction_type.dart';

extension TransactionRowMapper on TransactionRow {
  TransactionEntry toDomain() {
    return TransactionEntry(
      id: id,
      accountId: accountId,
      type: TransactionType.values.byName(type),
      amount: amount,
      date: date,
      categoryId: categoryId,
      note: note,
      transferAccountId: transferAccountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension TransactionEntityMapper on TransactionEntry {
  /// Every field is set explicitly (even nullable ones, via `Value(...)`)
  /// rather than left absent, since `TransactionsDao` reads `.value` off
  /// these companions directly to compute balance effects.
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion.insert(
      id: id,
      accountId: accountId,
      categoryId: Value(categoryId),
      type: type.name,
      amount: amount,
      date: date,
      note: Value(note),
      transferAccountId: Value(transferAccountId),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
