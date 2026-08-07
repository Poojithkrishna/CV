import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_direction.dart';

class LoanTile extends StatelessWidget {
  const LoanTile({super.key, required this.loan, this.onTap});

  final Loan loan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isGiven = loan.direction == LoanDirection.given;
    final Gradient gradient = isGiven ? AppGradients.finance : AppGradients.fitness;

    return GradientCard(
      gradient: gradient,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isGiven ? Icons.call_made_rounded : Icons.call_received_rounded, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loan.personName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (loan.isSettled)
                const Icon(Icons.check_circle_rounded, size: 18)
              else if (loan.dueDate != null)
                Text(
                  'Due ${AppFormatters.shortDate(loan.dueDate!)}',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppFormatters.currency(loan.remainingAmount),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            loan.isSettled ? 'Settled' : 'remaining of ${AppFormatters.currency(loan.principalAmount)}',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
          ),
          const SizedBox(height: 12),
          LabeledProgressBar(
            progress: loan.progress,
            leadingLabel: '${AppFormatters.currency(loan.amountPaid)} paid',
            trailingLabel: '${(loan.progress * 100).toStringAsFixed(0)}%',
            color: Colors.white,
            trackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
