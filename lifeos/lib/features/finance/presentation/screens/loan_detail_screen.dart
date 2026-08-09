import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/notification_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../notifications/loan_reminders.dart';
import '../providers/loan_providers.dart';
import '../widgets/loan_payment_tile.dart';

final Uuid _uuid = Uuid();

class LoanDetailScreen extends ConsumerWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  Future<void> _recordPayment(BuildContext context, WidgetRef ref, Loan loan) async {
    final double? amount = await showAmountInputDialog(
      context,
      title: 'Record a payment',
      maxAmount: loan.remainingAmount,
    );
    if (amount == null) return;

    final DateTime now = DateTime.now();
    final LoanPayment payment = LoanPayment(
      id: _uuid.v4(),
      loanId: loan.id,
      amount: amount,
      date: now,
      createdAt: now,
    );

    final result = await ref.read(recordLoanPaymentUseCaseProvider).call(loan, payment);
    if (!context.mounted) return;

    if (result.isOk) {
      // The payment stream hasn't necessarily refreshed yet, so derive
      // whether this payment just settled the loan directly rather than
      // re-reading it.
      if (loan.remainingAmount - amount <= 0) {
        await cancelLoanReminder(ref.read(notificationServiceProvider), loan.id);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureOrNull!.message)),
      );
    }
  }

  Future<void> _deletePayment(BuildContext context, WidgetRef ref, String paymentId) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete payment?',
      message: 'This restores the amount back onto the loan\'s remaining balance.',
    );
    if (!confirmed) return;
    await ref.read(deleteLoanPaymentUseCaseProvider).call(paymentId);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete loan?',
      message: 'This permanently removes the loan and its payment history.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteLoanUseCaseProvider).call(loanId);
    if (!context.mounted) return;

    if (result.isOk) {
      await cancelLoanReminder(ref.read(notificationServiceProvider), loanId);
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
    final AsyncValue<Loan?> loanAsync = ref.watch(loanByIdProvider(loanId));

    return loanAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load loan: $error')),
      ),
      data: (Loan? loan) {
        if (loan == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Loan not found.')));
        }

        final AsyncValue<List<LoanPayment>> paymentsAsync =
            ref.watch(paymentsForLoanProvider(loanId));

        return Scaffold(
          appBar: AppBar(
            title: Text(loan.personName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/finance/loans/${loan.id}/edit'),
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
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.direction.label, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(loan.remainingAmount),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      loan.isSettled
                          ? 'Settled'
                          : 'remaining of ${AppFormatters.currency(loan.principalAmount)}',
                    ),
                    const SizedBox(height: 16),
                    LabeledProgressBar(
                      progress: loan.progress,
                      leadingLabel: '${AppFormatters.currency(loan.amountPaid)} paid',
                      trailingLabel: '${(loan.progress * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!loan.isSettled)
                FilledButton.icon(
                  onPressed: () => _recordPayment(context, ref, loan),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Record payment'),
                ),
              const SizedBox(height: 24),
              if (loan.personPhone != null)
                _DetailRow(label: 'Phone', value: loan.personPhone!),
              if (loan.dueDate != null)
                _DetailRow(label: 'Due date', value: AppFormatters.shortDate(loan.dueDate!)),
              if (loan.notes != null) ...[
                const SizedBox(height: 12),
                Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(loan.notes!),
              ],
              const SizedBox(height: 24),
              Text(
                'Payment history',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              paymentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (List<LoanPayment> payments) {
                  if (payments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No payments recorded yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final LoanPayment payment in payments)
                        LoanPaymentTile(
                          payment: payment,
                          onDelete: () => _deletePayment(context, ref, payment.id),
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
