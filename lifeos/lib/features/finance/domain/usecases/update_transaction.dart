import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/transaction_entry.dart';
import '../repositories/transaction_repository.dart';
import 'create_transaction.dart';

class UpdateTransaction {
  UpdateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<TransactionEntry>> call(TransactionEntry entry) async {
    final Failure? error = CreateTransaction.validate(entry);
    if (error != null) return Result.err(error);
    return _repository.updateTransaction(entry.copyWith(updatedAt: DateTime.now()));
  }
}
