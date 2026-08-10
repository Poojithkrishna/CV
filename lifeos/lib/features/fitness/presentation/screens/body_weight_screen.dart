import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/trend_line_chart.dart';
import '../../domain/entities/body_weight_entry.dart';
import '../../domain/services/body_weight_stats.dart';
import '../providers/body_weight_providers.dart';
import '../../../../app/origin/origin_glyphs.dart';

final Uuid _uuid = Uuid();
final Color _accentColor = AppGradients.fitness.colors.first;

class BodyWeightScreen extends ConsumerWidget {
  const BodyWeightScreen({super.key});

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _logToday(BuildContext context, WidgetRef ref, List<BodyWeightEntry> entries) async {
    final DateTime today = _normalize(DateTime.now());
    final Iterable<BodyWeightEntry> matches = entries.where((e) => e.date == today);
    final BodyWeightEntry? existing = matches.isEmpty ? null : matches.first;

    final double? weight = await showAmountInputDialog(
      context,
      title: 'Log today\'s weight',
      label: 'Weight (kg)',
      initialValue: existing?.weightKg,
    );
    if (weight == null) return;

    final DateTime now = DateTime.now();
    final BodyWeightEntry entry = BodyWeightEntry(
      id: existing?.id ?? _uuid.v4(),
      date: today,
      weightKg: weight,
      notes: existing?.notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref.read(logBodyWeightUseCaseProvider).call(entry);
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
    await ref.read(deleteBodyWeightEntryUseCaseProvider).call(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BodyWeightEntry>> entriesAsync = ref.watch(bodyWeightEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Body Weight')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _logToday(context, ref, entriesAsync.valueOrNull ?? const []),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Log weight'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<BodyWeightEntry> ascending) {
          if (ascending.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.fitness,
              icon: Icons.monitor_weight_outlined,
              title: 'No weigh-ins yet',
              message: 'Log your weight regularly to see your trend over time.',
              actionLabel: 'Log today\'s weight',
              onAction: () => _logToday(context, ref, ascending),
            );
          }

          final List<BodyWeightEntry> descending = ascending.reversed.toList();
          final BodyWeightEntry latest = ascending.last;
          final double? weekChange = BodyWeightStats.changeOverDays(
            entriesAscending: ascending,
            days: 7,
            asOf: DateTime.now(),
          );
          final double? monthChange = BodyWeightStats.changeOverDays(
            entriesAscending: ascending,
            days: 30,
            asOf: DateTime.now(),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Current',
                      value: '${latest.weightKg.toStringAsFixed(1)} kg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: '7 days', value: _changeLabel(weekChange)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: '30 days', value: _changeLabel(monthChange)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TrendLineChart(
                valuesAscending: [for (final BodyWeightEntry e in ascending) e.weightKg],
                color: _accentColor,
              ),
              const SizedBox(height: 20),
              Text(
                'History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              for (final BodyWeightEntry entry in descending)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${entry.weightKg.toStringAsFixed(1)} kg'),
                    subtitle: Text(AppFormatters.shortDate(entry.date)),
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

  String _changeLabel(double? change) {
    if (change == null) return '—';
    final String sign = change > 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
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
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
