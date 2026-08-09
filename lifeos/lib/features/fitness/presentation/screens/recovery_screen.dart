import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/trend_line_chart.dart';
import '../../domain/entities/recovery_entry.dart';
import '../../domain/services/recovery_stats.dart';
import '../providers/recovery_providers.dart';

final Uuid _uuid = Uuid();
final Color _accentColor = AppGradients.fitness.colors.first;

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _logToday(BuildContext context, WidgetRef ref, RecoveryEntry? existing) async {
    final TextEditingController sleepController = TextEditingController(
      text: existing?.sleepHours?.toStringAsFixed(1) ?? '',
    );
    final TextEditingController notesController = TextEditingController(text: existing?.notes ?? '');
    int soreness = existing?.sorenessLevel ?? 3;
    int stress = existing?.stressLevel ?? 3;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log recovery'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Sleep hours (optional)',
                  controller: sleepController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: decimalInputFormatters,
                ),
                const SizedBox(height: 16),
                Text('Soreness: $soreness / 5'),
                Slider(
                  value: soreness.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$soreness',
                  onChanged: (value) => setState(() => soreness = value.round()),
                ),
                Text('Stress: $stress / 5'),
                Slider(
                  value: stress.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$stress',
                  onChanged: (value) => setState(() => stress = value.round()),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Notes (optional)',
                  controller: notesController,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final DateTime today = _normalize(DateTime.now());
    final DateTime now = DateTime.now();
    final RecoveryEntry entry = RecoveryEntry(
      id: existing?.id ?? _uuid.v4(),
      date: today,
      sleepHours:
          sleepController.text.trim().isEmpty ? null : double.tryParse(sleepController.text),
      sorenessLevel: soreness,
      stressLevel: stress,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref.read(logRecoveryUseCaseProvider).call(entry);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref, String id) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete entry?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    await ref.read(deleteRecoveryEntryUseCaseProvider).call(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RecoveryEntry>> entriesAsync = ref.watch(recoveryEntriesProvider);
    final AsyncValue<RecoveryEntry?> todayAsync = ref.watch(todayRecoveryEntryProvider);
    final RecoveryEntry? today = todayAsync.valueOrNull;
    final double? todayScore = today == null ? null : RecoveryStats.score(today);

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logToday(context, ref, today),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log today'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<RecoveryEntry> ascending) {
          final List<RecoveryEntry> descending = ascending.reversed.toList();
          final List<double> sleepValues = [
            for (final RecoveryEntry e in ascending)
              if (e.sleepHours != null) e.sleepHours!,
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: "Today's score",
                      value: todayScore == null ? '—' : todayScore.toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Sleep last night',
                      value: today?.sleepHours == null
                          ? '—'
                          : '${today!.sleepHours!.toStringAsFixed(1)} h',
                    ),
                  ),
                ],
              ),
              if (sleepValues.length >= 2) ...[
                const SizedBox(height: 20),
                Text(
                  'Sleep trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                TrendLineChart(valuesAscending: sleepValues, color: _accentColor),
              ],
              const SizedBox(height: 20),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              if (descending.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No recovery entries yet — log today\'s sleep, soreness and stress.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                for (final RecoveryEntry entry in descending)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(AppFormatters.shortDate(entry.date)),
                      subtitle: Text(
                        [
                          if (entry.sleepHours != null) '${entry.sleepHours!.toStringAsFixed(1)}h sleep',
                          if (entry.sorenessLevel != null) 'soreness ${entry.sorenessLevel}/5',
                          if (entry.stressLevel != null) 'stress ${entry.stressLevel}/5',
                        ].join(' · '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteEntry(context, ref, entry.id),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
