import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/monthly_totals.dart';

/// A grouped bar chart — income and expense side by side per month, oldest
/// first — for the Analytics screen's income-vs-expense trend.
class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key, required this.months});

  final List<MonthlyTotals> months;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) return const SizedBox.shrink();

    final double maxValue = months
        .map((m) => m.income > m.expense ? m.income : m.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final double maxY = maxValue <= 0 ? 1 : maxValue * 1.2;
    const Color incomeColor = Color(0xFF16A34A);
    const Color expenseColor = Color(0xFFDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= months.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('MMM').format(months[index].month),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < months.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: months[i].income,
                        color: incomeColor,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: months[i].expense,
                        color: expenseColor,
                        width: 8,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                    barsSpace: 4,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: incomeColor, label: 'Income'),
            const SizedBox(width: 20),
            _LegendDot(color: expenseColor, label: 'Expense'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
