import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/transaction_entry.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<TransactionEntry>> call(TransactionEntry entry) async {
    final Failure? error = validate(entry);
    if (error != null) return Result.err(error);
    return _repository.createTransaction(entry);
  }

  /// Shared by create and update so both enforce the same invariants.
  static Failure? validate(TransactionEntry entry) {
    if (entry.amount <= 0) {
      return const ValidationFailure('Amount must be greater than zero.');
    }
    if (entry.type == TransactionType.transfer) {
      if (entry.transferAccountId == null) {
        return const ValidationFailure('Choose a destination account for the transfer.');
      }
      if (entry.transferAccountId == entry.accountId) {
        return const ValidationFailure('Transfer destination must be a different account.');
      }
    } else if (entry.transferAccountId != null) {
      return const ValidationFailure(
        'Only transfers can have a destination account.',
      );
    }
    return null;
  }
}
