import 'package:flutter/material.dart';

/// A progress bar with a label row above it (left/right captions) — used
/// for credit card utilization, loan payoff progress and EMI progress.
class LabeledProgressBar extends StatelessWidget {
  const LabeledProgressBar({
    super.key,
    required this.progress,
    required this.leadingLabel,
    required this.trailingLabel,
    this.color,
    this.trackColor,
  });

  /// 0-1; values outside that range are clamped for the bar itself (the
  /// labels can still show the true, un-clamped figures).
  final double progress;
  final String leadingLabel;
  final String trailingLabel;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leadingLabel, style: Theme.of(context).textTheme.bodySmall),
            Text(trailingLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: trackColor,
            valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
          ),
        ),
      ],
    );
  }
}
