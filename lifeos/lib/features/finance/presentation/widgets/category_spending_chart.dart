import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/category_spending.dart';

/// A donut chart of this month's expense categories, largest first, with
/// a legend list underneath (categories beyond a chart's usable slice
/// count still show up there with their exact amount).
class CategorySpendingChart extends StatelessWidget {
  const CategorySpendingChart({super.key, required this.spending});

  final List<CategorySpending> spending;

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) return const SizedBox.shrink();

    final double total = spending.fold<double>(0, (sum, s) => sum + s.amount);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: [
                for (final CategorySpending entry in spending)
                  PieChartSectionData(
                    value: entry.amount,
                    color: Color(entry.category.colorValue),
                    title: '',
                    radius: 36,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final CategorySpending entry in spending)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(entry.category.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(entry.category.name)),
                Text(
                  AppFormatters.currency(entry.amount),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  total <= 0 ? '0%' : '${(entry.amount / total * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
