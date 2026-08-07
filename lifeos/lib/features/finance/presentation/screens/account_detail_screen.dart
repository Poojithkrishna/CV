import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/account.dart';
import '../providers/finance_providers.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete account?',
      message:
          'This permanently removes the account. Any linked transactions will keep '
          'a reference to a deleted account until you build the Transactions module.',
    );
    if (!confirmed) return;

    final result = await ref.read(deleteAccountUseCaseProvider).call(accountId);
    if (!context.mounted) return;

    result.when(
      ok: (_) => context.pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Account?> accountAsync = ref.watch(accountByIdProvider(accountId));

    return accountAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load account: $error')),
      ),
      data: (Account? account) {
        if (account == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Account not found.')),
          );
        }

        final Color color = Color(account.colorValue);

        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/finance/accounts/${account.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.black, 0.35)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.type.label,
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(account.currentBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: 'Opening balance',
                value: AppFormatters.currency(account.openingBalance),
              ),
              _DetailRow(
                label: 'Net change',
                value: AppFormatters.currency(account.netChange),
              ),
              if (account.bankName != null)
                _DetailRow(label: 'Bank / provider', value: account.bankName!),
              if (account.accountNumber != null)
                _DetailRow(label: 'Account number', value: account.maskedAccountNumber),
              if (account.interestRate != null)
                _DetailRow(
                  label: 'Interest rate',
                  value: '${account.interestRate!.toStringAsFixed(2)}%',
                ),
              _DetailRow(
                label: 'Created',
                value: AppFormatters.shortDate(account.createdAt),
              ),
              if (account.notes != null) ...[
                const SizedBox(height: 16),
                Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(account.notes!),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
