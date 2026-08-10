import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/recurring_payment.dart';
import '../providers/recurring_payment_providers.dart';
import '../widgets/recurring_payment_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

/// Bills & recurring payments, sorted by due date (soonest first, which
/// the DAO already guarantees) with overdue ones surfaced at the top via
/// a dedicated section.
class RecurringPaymentsListScreen extends ConsumerWidget {
  const RecurringPaymentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RecurringPayment>> paymentsAsync =
        ref.watch(activeRecurringPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills & Recurring Payments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/recurring-payments/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Payment'),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<RecurringPayment> payments) {
          if (payments.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.wealth,
              icon: Icons.receipt_long_outlined,
              title: 'No bills or subscriptions yet',
              message: 'Track rent, subscriptions and other recurring payments here.',
              actionLabel: 'Add your first one',
              onAction: () => context.push('/finance/recurring-payments/new'),
            );
          }

          final List<RecurringPayment> overdue = payments.where((p) => p.isOverdue).toList();
          final List<RecurringPayment> upcoming = payments.where((p) => !p.isOverdue).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (overdue.isNotEmpty) ...[
                _SectionHeader(title: 'Overdue'),
                for (final RecurringPayment payment in overdue)
                  RecurringPaymentTile(
                    payment: payment,
                    onTap: () => context.push('/finance/recurring-payments/${payment.id}'),
                  ),
                const SizedBox(height: 8),
              ],
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Upcoming'),
                for (final RecurringPayment payment in upcoming)
                  RecurringPaymentTile(
                    payment: payment,
                    onTap: () => context.push('/finance/recurring-payments/${payment.id}'),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
