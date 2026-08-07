import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/accounts_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// Non-archived accounts, ordered for display (manual sort order, then
  /// most-recently-created first).
  Stream<List<AccountRow>> watchActiveAccounts() {
    return (select(accounts)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.sortOrder),
            (tbl) => OrderingTerm.desc(tbl.createdAt),
          ]))
        .watch();
  }

  Stream<List<AccountRow>> watchArchivedAccounts() {
    return (select(accounts)
          ..where((tbl) => tbl.isArchived.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .watch();
  }

  Stream<AccountRow?> watchAccount(String id) {
    return (select(accounts)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<AccountRow?> getAccount(String id) {
    return (select(accounts)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertAccount(AccountsCompanion entry) {
    return into(accounts).insert(entry);
  }

  Future<bool> updateAccount(AccountsCompanion entry) {
    return update(accounts).replace(entry);
  }

  Future<int> deleteAccount(String id) {
    return (delete(accounts)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Sum of every non-archived account's current balance, split into
  /// assets and liabilities, so callers can compute net worth as
  /// `assets - liabilities` (kept as two numbers rather than one so the
  /// dashboard can show both breakdowns).
  Future<({double assets, double liabilities})> getBalanceTotals(
    Set<String> liabilityTypeNames,
  ) async {
    final List<AccountRow> rows = await (select(accounts)
          ..where((tbl) => tbl.isArchived.equals(false)))
        .get();

    double assets = 0;
    double liabilities = 0;
    for (final AccountRow row in rows) {
      if (liabilityTypeNames.contains(row.accountType)) {
        liabilities += row.currentBalance.abs();
      } else {
        assets += row.currentBalance;
      }
    }
    return (assets: assets, liabilities: liabilities);
  }
}
