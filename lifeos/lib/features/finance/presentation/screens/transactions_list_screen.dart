import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/transaction_entry.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_tile.dart';

/// Full transaction history. When [accountId] is provided, scoped to just
/// that account's transactions (including transfers in or out of it);
/// otherwise shows the most recent transactions across every account.
class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key, this.accountId});

  final String? accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TransactionEntry>> transactionsAsync = accountId != null
        ? ref.watch(transactionsForAccountProvider(accountId!))
        : ref.watch(recentTransactionsProvider(500));

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          accountId != null
              ? '/finance/transactions/new?accountId=$accountId'
              : '/finance/transactions/new',
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Transaction'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<TransactionEntry> transactions) {
          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              message: 'Log income, expenses and transfers to see them here.',
              actionLabel: 'Add your first transaction',
              onAction: () => context.push('/finance/transactions/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final TransactionEntry entry = transactions[index];
              return TransactionTile(
                entry: entry,
                onTap: () => context.push('/finance/transactions/${entry.id}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}
