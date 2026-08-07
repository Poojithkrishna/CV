import '../../../../core/utils/result.dart';
import '../entities/transaction_entry.dart';

abstract interface class TransactionRepository {
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit});
  Stream<List<TransactionEntry>> watchTransactionsForAccount(String accountId);
  Stream<TransactionEntry?> watchTransaction(String id);

  Future<Result<TransactionEntry>> createTransaction(TransactionEntry entry);
  Future<Result<TransactionEntry>> updateTransaction(TransactionEntry entry);
  Future<Result<void>> deleteTransaction(String id);
}
