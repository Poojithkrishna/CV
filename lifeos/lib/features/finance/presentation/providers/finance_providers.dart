import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/accounts_dao.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/update_account.dart';

final Provider<AccountsDao> accountsDaoProvider = Provider<AccountsDao>((ref) {
  return AccountsDao(ref.watch(appDatabaseProvider));
});

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountsDaoProvider));
});

final Provider<CreateAccount> createAccountUseCaseProvider = Provider(
  (ref) => CreateAccount(ref.watch(accountRepositoryProvider)),
);

final Provider<UpdateAccount> updateAccountUseCaseProvider = Provider(
  (ref) => UpdateAccount(ref.watch(accountRepositoryProvider)),
);

final Provider<DeleteAccount> deleteAccountUseCaseProvider = Provider(
  (ref) => DeleteAccount(ref.watch(accountRepositoryProvider)),
);

/// Live list of non-archived accounts, ordered for display.
final StreamProvider<List<Account>> activeAccountsProvider =
    StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchActiveAccounts();
});

final StreamProvider<List<Account>> archivedAccountsProvider =
    StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchArchivedAccounts();
});

final StreamProviderFamily<Account?, String> accountByIdProvider =
    StreamProvider.family<Account?, String>((ref, id) {
  return ref.watch(accountRepositoryProvider).watchAccount(id);
});

/// Derived, always-in-sync net worth summary computed straight from the
/// active-accounts stream rather than a separate DB query, so it updates
/// the instant any account balance changes.
final Provider<AsyncValue<NetWorthSummary>> netWorthSummaryProvider =
    Provider<AsyncValue<NetWorthSummary>>((ref) {
  final AsyncValue<List<Account>> accounts = ref.watch(activeAccountsProvider);
  return accounts.whenData((List<Account> list) {
    double assets = 0;
    double liabilities = 0;
    for (final Account account in list) {
      if (account.type.isLiability) {
        liabilities += account.currentBalance.abs();
      } else {
        assets += account.currentBalance;
      }
    }
    return (assets: assets, liabilities: liabilities, netWorth: assets - liabilities);
  });
});
