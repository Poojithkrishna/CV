import 'package:flutter/material.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/repositories/account_repository.dart';

/// Headline net-worth tile shown at the top of the Finance tab and on the
/// dashboard: net worth plus its assets/liabilities breakdown.
class NetWorthSummaryCard extends StatelessWidget {
  const NetWorthSummaryCard({super.key, required this.summary});

  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppGradients.finance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NET WORTH',
            style: TextStyle(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency(summary.netWorth),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Assets',
                  value: AppFormatters.currencyCompact(summary.assets),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withOpacity(0.25),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Liabilities',
                  value: AppFormatters.currencyCompact(summary.liabilities),
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.85)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
