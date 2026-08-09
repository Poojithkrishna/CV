import '../../../../core/utils/result.dart';
import '../entities/account.dart';

/// Net assets vs. liabilities across every active account.
typedef NetWorthSummary = ({double assets, double liabilities, double netWorth});

abstract interface class AccountRepository {
  Stream<List<Account>> watchActiveAccounts();
  Stream<List<Account>> watchArchivedAccounts();
  Stream<Account?> watchAccount(String id);

  Future<Result<Account>> createAccount(Account account);
  Future<Result<Account>> updateAccount(Account account);
  Future<Result<void>> archiveAccount(String id, {required bool archived});
  Future<Result<void>> deleteAccount(String id);

  Future<NetWorthSummary> getNetWorthSummary();
}
