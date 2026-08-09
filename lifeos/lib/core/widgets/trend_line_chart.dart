import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A simple, unlabeled trend line for a short series of chronological
/// values — used wherever a quick "is this going up or down" glance
/// matters more than a fully-labeled chart (body weight, measurements).
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.valuesAscending, required this.color});

  final List<double> valuesAscending;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (valuesAscending.length < 2) return const SizedBox.shrink();

    final List<FlSpot> spots = [
      for (int i = 0; i < valuesAscending.length; i++) FlSpot(i.toDouble(), valuesAscending[i]),
    ];
    final double minY = valuesAscending.reduce((a, b) => a < b ? a : b);
    final double maxY = valuesAscending.reduce((a, b) => a > b ? a : b);
    final double padding = (maxY - minY).clamp(1, double.infinity).toDouble() * 0.15;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: color,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.12)),
            ),
          ],
        ),
      ),
    );
  }
}
