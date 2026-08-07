import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/card_emi.dart';

class EmiTile extends StatelessWidget {
  const EmiTile({
    super.key,
    required this.emi,
    required this.onMarkPaid,
    required this.onDelete,
  });

  final CardEmi emi;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    emi.description,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            Text(
              '${AppFormatters.currency(emi.monthlyAmount)}/mo · '
              '${AppFormatters.currency(emi.remainingAmount)} remaining',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            LabeledProgressBar(
              progress: emi.progress,
              leadingLabel: '${emi.monthsPaid}/${emi.tenureMonths} months',
              trailingLabel: emi.isPaidOff ? 'Paid off' : '${emi.remainingMonths} left',
            ),
            if (!emi.isPaidOff) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onMarkPaid,
                  child: const Text('Mark month paid'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
