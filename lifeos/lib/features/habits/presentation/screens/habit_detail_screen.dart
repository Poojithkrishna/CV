import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/habit_type.dart';
import '../../domain/services/habit_stats.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_heatmap.dart';

const int _heatmapPeriods = 84;

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  Future<void> _logAmount(BuildContext context, WidgetRef ref, Habit habit) async {
    final double? amount = await showAmountInputDialog(
      context,
      title: 'Log ${habit.name}',
      label: habit.unit ?? 'Amount',
    );
    if (amount == null) return;
    await ref.read(logHabitProgressUseCaseProvider).call(habit, amount);
  }

  Future<void> _toggleYesNo(WidgetRef ref, Habit habit, HabitEntry? entry) async {
    final double delta = (entry?.isCompleteFor(habit) ?? false)
        ? -(entry?.progressValue ?? 0)
        : habit.targetValue;
    await ref.read(logHabitProgressUseCaseProvider).call(habit, delta);
  }

  Future<void> _toggleChecklistItem(WidgetRef ref, Habit habit, int index) async {
    await ref.read(toggleHabitChecklistItemUseCaseProvider).call(habit, index);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete habit?',
      message: 'This permanently removes the habit and its entire history.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteHabitUseCaseProvider).call(habitId);
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
    final AsyncValue<Habit?> habitAsync = ref.watch(habitByIdProvider(habitId));

    return habitAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load habit: $error')),
      ),
      data: (Habit? habit) {
        if (habit == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Habit not found.')));
        }

        final Color color = Color(habit.colorValue);
        final AsyncValue<List<HabitEntry>> entriesAsync =
            ref.watch(entriesForHabitProvider(habitId));
        final DateTime now = DateTime.now();
        final DateTime periodStart = habit.frequency.periodStart(now);
        final AsyncValue<HabitEntry?> currentEntryAsync =
            ref.watch(entryForPeriodProvider((habitId: habitId, periodStart: periodStart)));

        return Scaffold(
          appBar: AppBar(
            title: Text(habit.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/habits/${habit.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
          body: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Something went wrong: $error')),
            data: (List<HabitEntry> entries) {
              final Set<DateTime> completedPeriods =
                  entries.where((e) => e.isCompleteFor(habit)).map((e) => e.periodStart).toSet();
              final int currentStreak = HabitStats.currentStreak(
                habit: habit,
                completedPeriods: completedPeriods,
                asOf: now,
              );
              final int longestStreak = HabitStats.longestStreak(
                habit: habit,
                completedPeriods: completedPeriods,
              );
              final DateTime heatmapStart = _startForHeatmap(habit, now);
              final double completionRate = HabitStats.completionRate(
                habit: habit,
                completedPeriods: completedPeriods,
                from: heatmapStart,
                to: now,
              );
              final Map<DateTime, double> heatmap = HabitStats.heatmapData(
                habit: habit,
                entries: entries,
                from: heatmapStart,
                to: now,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Current streak',
                          value: '$currentStreak',
                          icon: Icons.local_fire_department_rounded,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Longest streak',
                          value: '$longestStreak',
                          icon: Icons.emoji_events_outlined,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Completion',
                          value: '${(completionRate * 100).toStringAsFixed(0)}%',
                          icon: Icons.donut_large_rounded,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Last 12 weeks', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 12),
                  HabitHeatmap(data: heatmap, color: color),
                  const SizedBox(height: 24),
                  Text('This period', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 12),
                  currentEntryAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (HabitEntry? entry) => _CurrentPeriodCard(
                      habit: habit,
                      entry: entry,
                      color: color,
                      onLogAmount: () => _logAmount(context, ref, habit),
                      onToggleYesNo: () => _toggleYesNo(ref, habit, entry),
                      onToggleChecklistItem: (index) => _toggleChecklistItem(ref, habit, index),
                    ),
                  ),
                  if (habit.notes != null) ...[
                    const SizedBox(height: 24),
                    Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(habit.notes!),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  DateTime _startForHeatmap(Habit habit, DateTime now) {
    DateTime cursor = habit.frequency.periodStart(now);
    for (int i = 0; i < _heatmapPeriods - 1; i++) {
      cursor = habit.frequency.previousPeriodStart(cursor);
    }
    return cursor;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CurrentPeriodCard extends StatelessWidget {
  const _CurrentPeriodCard({
    required this.habit,
    required this.entry,
    required this.color,
    required this.onLogAmount,
    required this.onToggleYesNo,
    required this.onToggleChecklistItem,
  });

  final Habit habit;
  final HabitEntry? entry;
  final Color color;
  final VoidCallback onLogAmount;
  final VoidCallback onToggleYesNo;
  final void Function(int index) onToggleChecklistItem;

  @override
  Widget build(BuildContext context) {
    if (habit.type == HabitType.checklist) {
      final Set<int> checked = entry?.checkedItemIndices ?? const {};
      return Card(
        child: Column(
          children: [
            for (int i = 0; i < habit.checklistItems.length; i++)
              CheckboxListTile(
                title: Text(habit.checklistItems[i]),
                value: checked.contains(i),
                onChanged: (_) => onToggleChecklistItem(i),
              ),
          ],
        ),
      );
    }

    if (habit.type == HabitType.yesNo) {
      final bool done = entry?.isCompleteFor(habit) ?? false;
      return Card(
        child: ListTile(
          leading: Icon(
            done ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: done ? color : null,
          ),
          title: Text(done ? 'Done' : 'Not done yet'),
          trailing: FilledButton(
            onPressed: onToggleYesNo,
            child: Text(done ? 'Undo' : 'Mark done'),
          ),
        ),
      );
    }

    final double progress = entry?.progressValue ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${progress.toStringAsFixed(progress.truncateToDouble() == progress ? 0 : 1)}'
                    ' / ${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)}'
                    '${habit.unit != null ? ' ${habit.unit}' : ''}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: habit.targetValue <= 0
                          ? 0
                          : (progress / habit.targetValue).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onLogAmount, child: const Text('Log')),
          ],
        ),
      ),
    );
  }
}
