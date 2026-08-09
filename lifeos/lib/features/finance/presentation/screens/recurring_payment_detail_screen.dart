import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/notification_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/recurring_payment.dart';
import '../notifications/recurring_payment_reminders.dart';
import '../providers/recurring_payment_providers.dart';

class RecurringPaymentDetailScreen extends ConsumerWidget {
  const RecurringPaymentDetailScreen({super.key, required this.paymentId});

  final String paymentId;

  Future<void> _markPaid(BuildContext context, WidgetRef ref, RecurringPayment payment) async {
    final double? amount = await showAmountInputDialog(
      context,
      title: 'Mark as paid',
      initialValue: payment.amount,
    );
    if (amount == null) return;

    final result = await ref
        .read(markRecurringPaymentPaidUseCaseProvider)
        .call(payment, actualAmount: amount);
    if (!context.mounted) return;

    if (result.isOk) {
      final RecurringPayment updated = result.valueOrNull!;
      await syncRecurringPaymentReminder(ref.read(notificationServiceProvider), updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Next due ${AppFormatters.shortDate(updated.nextDueDate)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureOrNull!.message)),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete?',
      message: 'This permanently removes this bill/subscription. It won\'t affect any '
          'transactions already logged from it.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteRecurringPaymentUseCaseProvider).call(paymentId);
    if (!context.mounted) return;

    if (result.isOk) {
      await cancelRecurringPaymentReminder(ref.read(notificationServiceProvider), paymentId);
      if (!context.mounted) return;
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureOrNull!.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RecurringPayment?> paymentAsync =
        ref.watch(recurringPaymentByIdProvider(paymentId));

    return paymentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load payment: $error')),
      ),
      data: (RecurringPayment? payment) {
        if (payment == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found.')));
        }

        final Color color = Color(payment.colorValue);

        return Scaffold(
          appBar: AppBar(
            title: Text(payment.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/finance/recurring-payments/${payment.id}/edit'),
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
                      payment.frequency.label,
                      style: TextStyle(color: Colors.white.withOpacity(0.85)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(payment.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      payment.isOverdue
                          ? 'Overdue since ${AppFormatters.shortDate(payment.nextDueDate)}'
                          : 'Next due ${AppFormatters.shortDate(payment.nextDueDate)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _markPaid(context, ref, payment),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as paid'),
              ),
              const SizedBox(height: 24),
              _DetailRow(label: 'Auto-pay', value: payment.isAutoPay ? 'Yes' : 'No'),
              if (payment.reminderDaysBefore != null)
                _DetailRow(
                  label: 'Reminder',
                  value: '${payment.reminderDaysBefore} day(s) before',
                ),
              if (payment.accountId == null)
                _DetailRow(label: 'Account', value: 'Not linked — schedule only'),
              if (payment.notes != null) ...[
                const SizedBox(height: 12),
                Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(payment.notes!),
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
