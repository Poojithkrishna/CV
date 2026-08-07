import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/card_emi.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_providers.dart';
import '../widgets/emi_tile.dart';

class CreditCardDetailScreen extends ConsumerWidget {
  const CreditCardDetailScreen({super.key, required this.cardId});

  final String cardId;

  Future<void> _recordCharge(BuildContext context, WidgetRef ref) async {
    final double? amount = await showAmountInputDialog(context, title: 'Log a charge');
    if (amount == null) return;
    final result = await ref.read(recordCardChargeUseCaseProvider).call(cardId, amount);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final double? amount = await showAmountInputDialog(context, title: 'Log a payment');
    if (amount == null) return;
    final result = await ref.read(recordCardPaymentUseCaseProvider).call(cardId, amount);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete card?',
      message: 'This permanently removes the card and its EMI records.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteCreditCardUseCaseProvider).call(cardId);
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
    final AsyncValue<CreditCard?> cardAsync = ref.watch(creditCardByIdProvider(cardId));

    return cardAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load card: $error')),
      ),
      data: (CreditCard? card) {
        if (card == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Card not found.')));
        }

        final Color color = Color(card.colorValue);
        final AsyncValue<List<CardEmi>> emisAsync = ref.watch(emisForCardProvider(cardId));

        return Scaffold(
          appBar: AppBar(
            title: Text(card.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/finance/credit-cards/${card.id}/edit'),
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
                      AppFormatters.currency(card.currentUsage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'of ${AppFormatters.currency(card.creditLimit)} limit',
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                    const SizedBox(height: 16),
                    LabeledProgressBar(
                      progress: card.utilization,
                      leadingLabel: '${(card.utilization * 100).clamp(0, 999).toStringAsFixed(0)}% used',
                      trailingLabel: '${AppFormatters.currency(card.availableCredit)} available',
                      color: Colors.white,
                      trackColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _recordCharge(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Log charge'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _recordPayment(context, ref),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Log payment'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: 'Statement day',
                value: card.statementDay != null ? '${card.statementDay}' : 'Not set',
              ),
              _DetailRow(
                label: 'Due day',
                value: card.dueDay != null ? '${card.dueDay}' : 'Not set',
              ),
              _DetailRow(label: 'Reward points', value: '${card.rewardPoints}'),
              _DetailRow(
                label: 'Cashback earned',
                value: AppFormatters.currency(card.cashbackEarned),
              ),
              if (card.annualFee != null)
                _DetailRow(label: 'Annual fee', value: AppFormatters.currency(card.annualFee!)),
              if (card.notes != null) ...[
                const SizedBox(height: 12),
                Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(card.notes!),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EMIs',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/finance/credit-cards/${card.id}/emis/new'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              emisAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (List<CardEmi> emis) {
                  if (emis.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No EMIs on this card.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final CardEmi emi in emis)
                        EmiTile(
                          emi: emi,
                          onMarkPaid: () =>
                              ref.read(markEmiInstallmentPaidUseCaseProvider).call(emi.id),
                          onDelete: () => ref.read(deleteCardEmiUseCaseProvider).call(emi.id),
                        ),
                    ],
                  );
                },
              ),
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
