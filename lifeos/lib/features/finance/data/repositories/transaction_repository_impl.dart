import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../daos/transactions_dao.dart';
import 'transaction_mapper.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dao);

  final TransactionsDao _dao;

  @override
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 20}) {
    return _dao
        .watchRecentTransactions(limit: limit)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<List<TransactionEntry>> watchTransactionsForAccount(String accountId) {
    return _dao
        .watchTransactionsForAccount(accountId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<List<TransactionEntry>> watchTransactionsBetween(DateTime from, DateTime to) {
    return _dao
        .watchTransactionsBetween(from, to)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<TransactionEntry?> watchTransaction(String id) {
    return _dao.watchTransaction(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<TransactionEntry>> createTransaction(TransactionEntry entry) async {
    try {
      await _dao.createTransaction(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save transaction: $e'));
    }
  }

  @override
  Future<Result<TransactionEntry>> updateTransaction(TransactionEntry entry) async {
    try {
      await _dao.updateTransaction(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update transaction: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await _dao.deleteTransaction(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete transaction: $e'));
    }
  }
}
