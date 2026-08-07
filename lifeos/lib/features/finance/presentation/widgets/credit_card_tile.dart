import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/credit_card.dart';

class CreditCardTile extends StatelessWidget {
  const CreditCardTile({super.key, required this.card, this.onTap});

  final CreditCard card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color base = Color(card.colorValue);

    return GradientCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [base, Color.lerp(base, Colors.black, 0.35)!],
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.bankName != null)
                      Text(
                        card.bankName!,
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (card.isOverLimit)
                const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFFFE082)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            AppFormatters.currency(card.currentUsage),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          Text(
            'of ${AppFormatters.currency(card.creditLimit)} limit',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
          ),
          const SizedBox(height: 14),
          LabeledProgressBar(
            progress: card.utilization,
            leadingLabel: '${(card.utilization * 100).clamp(0, 999).toStringAsFixed(0)}% used',
            trailingLabel: '${AppFormatters.currency(card.availableCredit)} available',
            color: Colors.white,
            trackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
