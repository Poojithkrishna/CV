import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_payment.dart';

class RecurringPaymentTile extends StatelessWidget {
  const RecurringPaymentTile({super.key, required this.payment, this.onTap});

  final RecurringPayment payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accent = Color(payment.colorValue);

    final (String statusLabel, Color statusColor) = payment.isOverdue
        ? ('Overdue', colorScheme.error)
        : payment.isDueSoon
            ? ('Due soon', const Color(0xFFF59E0B))
            : ('Upcoming', colorScheme.onSurfaceVariant);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.18),
          child: Icon(Icons.receipt_long_rounded, color: accent, size: 20),
        ),
        title: Text(payment.name, overflow: TextOverflow.ellipsis),
        subtitle: Text('${payment.frequency.label} · ${AppFormatters.shortDate(payment.nextDueDate)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency(payment.amount),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
