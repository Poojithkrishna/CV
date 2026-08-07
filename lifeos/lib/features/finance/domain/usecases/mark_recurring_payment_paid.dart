import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';
import '../entities/transaction_entry.dart';
import '../entities/transaction_type.dart';
import '../repositories/recurring_payment_repository.dart';
import 'create_transaction.dart';

final Uuid _uuid = Uuid();

/// Marks one occurrence of a recurring payment paid: if it's linked to an
/// account, logs a real expense transaction (so it shows up in that
/// account's history and balance, same as any other expense); either way,
/// advances `nextDueDate` to the following occurrence.
///
/// The transaction and the schedule update are two separate repository
/// calls rather than one atomic database transaction (unlike
/// `TransactionsDao`'s account-balance updates) — a reasonable trade-off
/// since a recurring payment and its generated transaction are more
/// loosely coupled, and the failure mode (transaction logged, schedule not
/// yet advanced) is recoverable rather than silently wrong.
class MarkRecurringPaymentPaid {
  MarkRecurringPaymentPaid(this._repository, this._createTransaction);

  final RecurringPaymentRepository _repository;
  final CreateTransaction _createTransaction;

  Future<Result<RecurringPayment>> call(
    RecurringPayment payment, {
    double? actualAmount,
    DateTime? paidDate,
  }) async {
    final double amount = actualAmount ?? payment.amount;
    if (amount <= 0) {
      return const Result.err(ValidationFailure('Amount must be greater than zero.'));
    }

    if (payment.accountId != null) {
      final DateTime now = DateTime.now();
      final TransactionEntry transaction = TransactionEntry(
        id: _uuid.v4(),
        accountId: payment.accountId!,
        type: TransactionType.expense,
        amount: amount,
        date: paidDate ?? now,
        categoryId: payment.categoryId,
        note: payment.name,
        createdAt: now,
        updatedAt: now,
      );
      final Result<TransactionEntry> transactionResult = await _createTransaction(transaction);
      if (transactionResult.isErr) {
        return Result.err(transactionResult.failureOrNull!);
      }
    }

    final RecurringPayment advanced = payment.copyWith(
      nextDueDate: payment.frequency.next(payment.nextDueDate),
      updatedAt: DateTime.now(),
    );
    return _repository.updatePayment(advanced);
  }
}
