import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// A GitHub-style completion heatmap: one square per period, shaded by
/// completion ratio (0-1). Wraps to the available width rather than
/// scrolling, so it reads fine on a phone.
class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({super.key, required this.data, required this.color});

  /// Period start -> completion ratio (0-1), in chronological order.
  final Map<DateTime, double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<DateTime, double>> entries = data.entries.toList();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final MapEntry<DateTime, double> entry in entries)
          Tooltip(
            message: '${AppFormatters.shortDate(entry.key)}: '
                '${(entry.value * 100).toStringAsFixed(0)}%',
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: entry.value <= 0
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : color.withOpacity(0.25 + entry.value * 0.75),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}
