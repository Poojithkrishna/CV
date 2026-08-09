import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/investment.dart';

class InvestmentTile extends StatelessWidget {
  const InvestmentTile({super.key, required this.investment, this.onTap});

  final Investment investment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(investment.colorValue);
    final bool isGain = investment.gainLoss >= 0;
    final Color gainColor = isGain ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(investment.type.icon, color: color, size: 20),
        ),
        title: Text(investment.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(investment.type.label),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency(investment.currentValue),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '${isGain ? '+' : ''}${AppFormatters.currency(investment.gainLoss)}'
              ' (${investment.gainLossPercent.toStringAsFixed(1)}%)',
              style: TextStyle(color: gainColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
