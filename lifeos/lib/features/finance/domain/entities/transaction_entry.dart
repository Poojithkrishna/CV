import 'package:flutter/foundation.dart';

import 'transaction_type.dart';

/// A single income, expense or transfer entry. Named `TransactionEntry`
/// (not `Transaction`) to avoid colliding with SQL/Drift's own notion of
/// a database transaction.
@immutable
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.note,
    this.transferAccountId,
  });

  final String id;
  final String accountId;
  final TransactionType type;

  /// Always positive; [type] determines how it affects account balances.
  final double amount;

  final DateTime date;

  /// Null for transfers — moving money between your own accounts is
  /// neither income nor spend.
  final String? categoryId;

  final String? note;

  /// Destination account for a transfer; null for income/expense.
  final String? transferAccountId;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTransfer => type == TransactionType.transfer;

  /// Signed amount as it affects [accountId]'s balance: positive for
  /// income, negative for expense and for the source leg of a transfer.
  double get signedAmount => type == TransactionType.income ? amount : -amount;

  TransactionEntry copyWith({
    String? accountId,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? categoryId,
    bool clearCategoryId = false,
    String? note,
    bool clearNote = false,
    String? transferAccountId,
    bool clearTransferAccountId = false,
    DateTime? updatedAt,
  }) {
    return TransactionEntry(
      id: id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      note: clearNote ? null : (note ?? this.note),
      transferAccountId:
          clearTransferAccountId ? null : (transferAccountId ?? this.transferAccountId),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is TransactionEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
