import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transaction_entry.dart';
import '../providers/finance_providers.dart';
import '../providers/transaction_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/net_worth_summary_card.dart';
import '../widgets/transaction_tile.dart';

const int _recentTransactionsLimit = 5;

/// Entry point for the Finance module: net worth summary, accounts, and a
/// peek at recent transactions. Credit cards, loans, bills and analytics
/// land here as their own sections in later passes.
class FinanceHomeScreen extends ConsumerWidget {
  const FinanceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(activeAccountsProvider);
    final AsyncValue netWorthAsync = ref.watch(netWorthSummaryProvider);
    final AsyncValue<List<TransactionEntry>> recentAsync =
        ref.watch(recentTransactionsProvider(_recentTransactionsLimit));

    final bool hasAccounts = accountsAsync.valueOrNull?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          IconButton(
            tooltip: 'Categories',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => context.push('/finance/categories'),
          ),
          IconButton(
            tooltip: 'Add account',
            icon: const Icon(Icons.add_card_outlined),
            onPressed: () => context.push('/finance/accounts/new'),
          ),
        ],
      ),
      floatingActionButton: hasAccounts
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/finance/transactions/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Transaction'),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.push('/finance/accounts/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Account'),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAccountsProvider);
        },
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Something went wrong: $error')),
          data: (List<Account> accounts) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: netWorthAsync.when(
                      loading: () => const SizedBox(height: 140),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (summary) => NetWorthSummaryCard(summary: summary),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Accounts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                if (accounts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No accounts yet',
                      message:
                          'Add your bank, cash, wallet or investment accounts to start tracking your net worth.',
                      actionLabel: 'Add your first account',
                      onAction: () => context.push('/finance/accounts/new'),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    sliver: SliverList.separated(
                      itemCount: accounts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final Account account = accounts[index];
                        return AccountCard(
                          account: account,
                          onTap: () => context.push('/finance/accounts/${account.id}'),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent transactions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/finance/transactions'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: recentAsync.when(
                      loading: () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                      data: (List<TransactionEntry> recent) {
                        if (recent.isEmpty) {
                          return SliverToBoxAdapter(
                            child: EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'No transactions yet',
                              message: 'Log your first income or expense.',
                              actionLabel: 'Add a transaction',
                              onAction: () => context.push('/finance/transactions/new'),
                            ),
                          );
                        }
                        return SliverList.separated(
                          itemCount: recent.length,
                          separatorBuilder: (_, __) => const SizedBox.shrink(),
                          itemBuilder: (context, index) {
                            final TransactionEntry entry = recent[index];
                            return TransactionTile(
                              entry: entry,
                              onTap: () =>
                                  context.push('/finance/transactions/${entry.id}/edit'),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
