import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/services/goal_stats.dart';
import '../providers/goal_providers.dart';

class GoalTile extends ConsumerWidget {
  const GoalTile({super.key, required this.goal, this.onTap});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = Color(goal.colorValue);
    final List<Milestone> milestones =
        ref.watch(milestonesForGoalProvider(goal.id)).valueOrNull ?? const [];
    final double progress = GoalStats.progress(goal, milestones);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.18),
                    child: Icon(Icons.flag_rounded, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (goal.targetDate != null)
                    Text(
                      AppFormatters.shortDate(goal.targetDate!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LabeledProgressBar(
                progress: progress,
                leadingLabel: milestones.isNotEmpty
                    ? '${milestones.where((m) => m.isCompleted).length}/${milestones.length} milestones'
                    : '${(progress * 100).toStringAsFixed(0)}%',
                trailingLabel: '${(progress * 100).toStringAsFixed(0)}%',
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
