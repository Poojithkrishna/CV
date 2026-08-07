import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/transactions_dao.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';

final Provider<TransactionsDao> transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return TransactionsDao(ref.watch(appDatabaseProvider));
});

final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionsDaoProvider));
});

final Provider<CreateTransaction> createTransactionUseCaseProvider = Provider(
  (ref) => CreateTransaction(ref.watch(transactionRepositoryProvider)),
);

final Provider<UpdateTransaction> updateTransactionUseCaseProvider = Provider(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final Provider<DeleteTransaction> deleteTransactionUseCaseProvider = Provider(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

/// Most recent transactions across every account — used on the Finance
/// home screen.
final StreamProviderFamily<List<TransactionEntry>, int> recentTransactionsProvider =
    StreamProvider.family<List<TransactionEntry>, int>((ref, limit) {
  return ref.watch(transactionRepositoryProvider).watchRecentTransactions(limit: limit);
});

final StreamProviderFamily<List<TransactionEntry>, String> transactionsForAccountProvider =
    StreamProvider.family<List<TransactionEntry>, String>((ref, accountId) {
  return ref.watch(transactionRepositoryProvider).watchTransactionsForAccount(accountId);
});

final StreamProviderFamily<TransactionEntry?, String> transactionByIdProvider =
    StreamProvider.family<TransactionEntry?, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).watchTransaction(id);
});
