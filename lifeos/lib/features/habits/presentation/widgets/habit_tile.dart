import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/entities/habit_type.dart';
import '../../domain/services/habit_stats.dart';
import '../providers/habit_providers.dart';

/// A habit row with a live quick-log action for its current period —
/// a toggle for yes/no habits, a "+1" for numeric ones, and a plain
/// progress readout for checklists (which need their own screen to check
/// off individual items).
class HabitTile extends ConsumerWidget {
  const HabitTile({super.key, required this.habit, this.onTap});

  final Habit habit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime periodStart = habit.frequency.periodStart(DateTime.now());
    final AsyncValue<HabitEntry?> entryAsync = ref.watch(
      entryForPeriodProvider((habitId: habit.id, periodStart: periodStart)),
    );
    final HabitEntry? entry = entryAsync.valueOrNull;
    final Color color = Color(habit.colorValue);

    final AsyncValue<List<HabitEntry>> entriesAsync =
        ref.watch(entriesForHabitProvider(habit.id));
    final int streak = entriesAsync.valueOrNull == null
        ? 0
        : HabitStats.currentStreak(
            habit: habit,
            completedPeriods: entriesAsync.valueOrNull!
                .where((e) => e.isCompleteFor(habit))
                .map((e) => e.periodStart)
                .toSet(),
            asOf: DateTime.now(),
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(habit.type.icon, color: color, size: 20),
        ),
        title: Text(habit.name, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Text(habit.frequency.label),
            if (streak > 0) ...[
              const SizedBox(width: 8),
              const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFF59E0B)),
              Text(' $streak', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ],
        ),
        trailing: _QuickLogAction(habit: habit, entry: entry, periodStart: periodStart),
      ),
    );
  }
}

class _QuickLogAction extends ConsumerWidget {
  const _QuickLogAction({required this.habit, required this.entry, required this.periodStart});

  final Habit habit;
  final HabitEntry? entry;
  final DateTime periodStart;

  Future<void> _increment(WidgetRef ref, double amount) async {
    await ref.read(logHabitProgressUseCaseProvider).call(habit, amount, asOf: periodStart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = Color(habit.colorValue);

    if (habit.type == HabitType.checklist) {
      final int total = habit.checklistItems.length;
      final int done = entry?.checkedItemIndices.length ?? 0;
      return Text('$done/$total', style: const TextStyle(fontWeight: FontWeight.w700));
    }

    if (habit.type == HabitType.yesNo) {
      final bool done = entry?.isCompleteFor(habit) ?? false;
      return IconButton(
        icon: Icon(
          done ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: done ? color : null,
        ),
        onPressed: () => _increment(ref, done ? -(entry?.progressValue ?? 0) : habit.targetValue),
      );
    }

    final double progress = entry?.progressValue ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${progress.toStringAsFixed(progress.truncateToDouble() == progress ? 0 : 1)}'
          '/${habit.targetValue.toStringAsFixed(habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1)}',
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: color),
          onPressed: () => _increment(ref, 1),
        ),
      ],
    );
  }
}
