import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/services/goal_stats.dart';
import '../providers/goal_providers.dart';
import '../widgets/milestone_tile.dart';

final Uuid _uuid = Uuid();

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  Future<void> _addMilestone(BuildContext context, WidgetRef ref, Goal goal) async {
    final TextEditingController controller = TextEditingController();
    final String? title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add milestone'),
        content: AppTextField(label: 'Milestone', controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    final int sortOrder = await ref.read(goalRepositoryProvider).nextMilestoneSortOrder(goal.id);
    final DateTime now = DateTime.now();
    final result = await ref.read(addMilestoneUseCaseProvider).call(
          Milestone(
            id: _uuid.v4(),
            goalId: goal.id,
            title: title,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _toggleMilestone(WidgetRef ref, String id) async {
    await ref.read(toggleMilestoneUseCaseProvider).call(id);
  }

  Future<void> _deleteMilestone(BuildContext context, WidgetRef ref, String id) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete milestone?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    await ref.read(deleteMilestoneUseCaseProvider).call(id);
  }

  Future<void> _linkHabit(BuildContext context, WidgetRef ref, Goal goal) async {
    final List<Habit> allHabits = ref.read(activeHabitsProvider).valueOrNull ?? const [];
    final Set<String> linkedIds =
        (ref.read(linkedHabitsForGoalProvider(goal.id)).valueOrNull ?? const [])
            .map((h) => h.id)
            .toSet();
    final List<Habit> candidates = allHabits.where((h) => !linkedIds.contains(h.id)).toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more habits to link.')),
      );
      return;
    }

    final String? habitId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link a habit'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final Habit habit = candidates[index];
              return ListTile(
                leading: Icon(habit.type.icon, color: Color(habit.colorValue)),
                title: Text(habit.name),
                onTap: () => Navigator.of(context).pop(habit.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (habitId == null) return;
    await ref.read(linkHabitToGoalUseCaseProvider).call(goal.id, habitId);
  }

  Future<void> _unlinkHabit(WidgetRef ref, String goalId, String habitId) async {
    await ref.read(unlinkHabitFromGoalUseCaseProvider).call(goalId, habitId);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete goal?',
      message: 'This permanently removes the goal and its milestones.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteGoalUseCaseProvider).call(goalId);
    if (!context.mounted) return;
    result.when(
      ok: (_) => context.pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Goal?> goalAsync = ref.watch(goalByIdProvider(goalId));

    return goalAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load goal: $error')),
      ),
      data: (Goal? goal) {
        if (goal == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Goal not found.')));
        }

        final Color color = Color(goal.colorValue);
        final List<Milestone> milestones =
            ref.watch(milestonesForGoalProvider(goalId)).valueOrNull ?? const [];
        final double progress = GoalStats.progress(goal, milestones);
        final List<Habit> linkedHabits =
            ref.watch(linkedHabitsForGoalProvider(goalId)).valueOrNull ?? const [];

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/goals/${goal.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% complete',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    if (goal.targetDate != null)
                      Text('Target: ${AppFormatters.shortDate(goal.targetDate!)}'),
                    const SizedBox(height: 16),
                    LabeledProgressBar(
                      progress: progress,
                      leadingLabel: milestones.isNotEmpty
                          ? '${milestones.where((m) => m.isCompleted).length}/${milestones.length} milestones'
                          : '${goal.progressValue.toStringAsFixed(0)}/${goal.targetValue.toStringAsFixed(0)}',
                      trailingLabel: '${(progress * 100).toStringAsFixed(0)}%',
                      color: color,
                    ),
                  ],
                ),
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 24),
                Text('Description', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text(goal.description!),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Milestones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _addMilestone(context, ref, goal),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (milestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No milestones yet — progress is tracked directly instead.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final Milestone milestone in milestones)
                  MilestoneTile(
                    milestone: milestone,
                    onToggle: () => _toggleMilestone(ref, milestone.id),
                    onDelete: () => _deleteMilestone(context, ref, milestone.id),
                  ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Linked habits',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _linkHabit(context, ref, goal),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Link'),
                  ),
                ],
              ),
              if (linkedHabits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Link a habit that contributes toward this goal.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final Habit habit in linkedHabits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(habit.type.icon, color: Color(habit.colorValue)),
                    title: Text(habit.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.link_off_rounded, size: 20),
                      onPressed: () => _unlinkHabit(ref, goal.id, habit.id),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
