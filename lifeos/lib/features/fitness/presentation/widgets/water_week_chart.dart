import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/water_entry.dart';

/// One bar per day for the last 7 days, scaled against [goalMl] so a full
/// bar means "hit the goal that day".
class WaterWeekChart extends StatelessWidget {
  const WaterWeekChart({
    super.key,
    required this.entriesAscending,
    required this.days,
    required this.goalMl,
    required this.color,
  });

  final List<WaterEntry> entriesAscending;
  final List<DateTime> days;
  final int goalMl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, int> byDate = {
      for (final WaterEntry entry in entriesAscending) entry.date: entry.amountMl,
    };
    final double maxValue = goalMl > 0 ? goalMl.toDouble() : 1;

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxValue * 1.15,
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
                  if (index < 0 || index >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('E').format(days[index]).substring(0, 1),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (byDate[days[i]] ?? 0).toDouble(),
                    color: color,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxValue,
                      color: color.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
