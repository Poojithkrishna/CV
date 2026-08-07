import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/repositories/account_repository.dart';
import '../daos/accounts_dao.dart';
import 'account_mapper.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._dao);

  final AccountsDao _dao;

  static final Set<String> _liabilityTypeNames = AccountType.values
      .where((type) => type.isLiability)
      .map((type) => type.name)
      .toSet();

  @override
  Stream<List<Account>> watchActiveAccounts() {
    return _dao.watchActiveAccounts().map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }

  @override
  Stream<List<Account>> watchArchivedAccounts() {
    return _dao.watchArchivedAccounts().map(
          (rows) => rows.map((row) => row.toDomain()).toList(growable: false),
        );
  }

  @override
  Stream<Account?> watchAccount(String id) {
    return _dao.watchAccount(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Account>> createAccount(Account account) async {
    try {
      await _dao.insertAccount(account.toCompanion());
      return Result.ok(account);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save account: $e'));
    }
  }

  @override
  Future<Result<Account>> updateAccount(Account account) async {
    try {
      final bool updated = await _dao.updateAccount(account.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Account no longer exists.'));
      }
      return Result.ok(account);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update account: $e'));
    }
  }

  @override
  Future<Result<void>> archiveAccount(String id, {required bool archived}) async {
    try {
      final AccountRow? row = await _dao.getAccount(id);
      if (row == null) {
        return const Result.err(NotFoundFailure('Account no longer exists.'));
      }
      await _dao.updateAccount(
        row.toCompanion(true).copyWith(
              isArchived: Value(archived),
              updatedAt: Value(DateTime.now()),
            ),
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update account: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String id) async {
    try {
      await _dao.deleteAccount(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete account: $e'));
    }
  }

  @override
  Future<NetWorthSummary> getNetWorthSummary() async {
    final totals = await _dao.getBalanceTotals(_liabilityTypeNames);
    return (
      assets: totals.assets,
      liabilities: totals.liabilities,
      netWorth: totals.assets - totals.liabilities,
    );
  }
}
