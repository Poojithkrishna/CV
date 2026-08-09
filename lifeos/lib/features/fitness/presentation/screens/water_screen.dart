import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/entities/water_goal.dart';
import '../providers/water_providers.dart';
import '../widgets/water_week_chart.dart';

const List<int> _quickAmountsMl = [150, 250, 500];
final Color _accentColor = AppGradients.finance.colors.first;

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  DateTime get _today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _add(WidgetRef ref, int amountMl) async {
    await ref.read(logWaterUseCaseProvider).call(_today, amountMl);
  }

  Future<void> _addCustom(BuildContext context, WidgetRef ref) async {
    final double? amount = await showAmountInputDialog(
      context,
      title: 'Add water',
      label: 'Amount (ml)',
    );
    if (amount == null) return;
    await _add(ref, amount.round());
  }

  Future<void> _editGoal(BuildContext context, WidgetRef ref, int currentGoal) async {
    final double? goal = await showAmountInputDialog(
      context,
      title: 'Daily goal',
      label: 'Goal (ml)',
      initialValue: currentGoal.toDouble(),
    );
    if (goal == null) return;
    final result = await ref.read(updateWaterGoalUseCaseProvider).call(goal.round());
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WaterEntry?> todayAsync = ref.watch(todayWaterEntryProvider);
    final AsyncValue<WaterGoal?> goalAsync = ref.watch(waterGoalProvider);
    final AsyncValue<List<WaterEntry>> weekAsync = ref.watch(weeklyWaterEntriesProvider);

    final int todayMl = todayAsync.valueOrNull?.amountMl ?? 0;
    final int goalMl = goalAsync.valueOrNull?.dailyGoalMl ?? 2500;
    final double progress = goalMl <= 0 ? 0 : (todayMl / goalMl).clamp(0, 1).toDouble();

    final List<DateTime> weekDays = [
      for (int i = 6; i >= 0; i--) _today.subtract(Duration(days: i)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _editGoal(context, ref, goalMl),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation(_accentColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$todayMl',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      Text('of $goalMl ml', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final int amount in _quickAmountsMl)
                OutlinedButton(
                  onPressed: () => _add(ref, amount),
                  child: Text('+$amount ml'),
                ),
              FilledButton.icon(
                onPressed: () => _addCustom(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Custom'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Last 7 days',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          weekAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (List<WaterEntry> entries) => WaterWeekChart(
              entriesAscending: entries,
              days: weekDays,
              goalMl: goalMl,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
