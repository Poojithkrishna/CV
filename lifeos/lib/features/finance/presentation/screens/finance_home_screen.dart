import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/transaction_entry.dart';
import '../providers/finance_providers.dart';
import '../providers/net_worth_provider.dart';
import '../providers/transaction_providers.dart';
import '../widgets/account_card.dart';
import '../widgets/net_worth_summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

const int _recentTransactionsLimit = 5;

/// Entry point for the Finance module: net worth summary, quick links to
/// every Finance sub-feature, accounts, and a peek at recent
/// transactions.
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
            tooltip: 'Add account',
            icon: const Icon(Icons.add_card_outlined),
            onPressed: () => context.push('/finance/accounts/new'),
          ),
        ],
      ),
      floatingActionButton: hasAccounts
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/finance/transactions/new'),
              icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
              label: const Text('Transaction'),
            )
          : FloatingActionButton.extended(
              onPressed: () => context.push('/finance/accounts/new'),
              icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _ToolChip(
                            icon: Icons.credit_card_outlined,
                            label: 'Credit Cards',
                            onTap: () => context.push('/finance/credit-cards'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.handshake_outlined,
                            label: 'Loans',
                            onTap: () => context.push('/finance/loans'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.receipt_long_outlined,
                            label: 'Bills',
                            onTap: () => context.push('/finance/recurring-payments'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.category_outlined,
                            label: 'Categories',
                            onTap: () => context.push('/finance/categories'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.trending_up_rounded,
                            label: 'Investments',
                            onTap: () => context.push('/finance/investments'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.inventory_2_outlined,
                            label: 'Assets',
                            onTap: () => context.push('/finance/assets'),
                          ),
                          const SizedBox(width: 8),
                          _ToolChip(
                            icon: Icons.insights_outlined,
                            label: 'Analytics',
                            onTap: () => context.push('/finance/analytics'),
                          ),
                        ],
                      ),
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
                      glyph: OriginGlyphType.wealth,
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
                              glyph: OriginGlyphType.wealth,
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

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
