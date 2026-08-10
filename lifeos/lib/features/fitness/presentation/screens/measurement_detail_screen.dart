import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_input_dialog.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/trend_line_chart.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/services/measurement_stats.dart';
import '../providers/measurement_providers.dart';
import '../../../../app/origin/origin_glyphs.dart';

final Uuid _uuid = Uuid();
final Color _accentColor = AppGradients.fitness.colors.first;

class MeasurementDetailScreen extends ConsumerWidget {
  const MeasurementDetailScreen({super.key, required this.type});

  final MeasurementType type;

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _log(BuildContext context, WidgetRef ref, List<MeasurementEntry> entries) async {
    final DateTime today = _normalize(DateTime.now());
    final Iterable<MeasurementEntry> matches = entries.where((e) => e.date == today);
    final MeasurementEntry? existing = matches.isEmpty ? null : matches.first;

    final double? value = await showAmountInputDialog(
      context,
      title: 'Log ${type.label}',
      label: 'Value (cm)',
      initialValue: existing?.valueCm,
    );
    if (value == null) return;

    final DateTime now = DateTime.now();
    final MeasurementEntry entry = MeasurementEntry(
      id: existing?.id ?? _uuid.v4(),
      type: type,
      date: today,
      valueCm: value,
      notes: existing?.notes,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref.read(logMeasurementUseCaseProvider).call(entry);
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
    await ref.read(deleteMeasurementUseCaseProvider).call(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<MeasurementEntry>> entriesAsync =
        ref.watch(entriesForMeasurementTypeProvider(type));

    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _log(context, ref, entriesAsync.valueOrNull ?? const []),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Log'),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<MeasurementEntry> ascending) {
          if (ascending.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.fitness,
              icon: type.icon,
              title: 'No entries yet',
              message: 'Log ${type.label.toLowerCase()} regularly to track your progress.',
              actionLabel: 'Log ${type.label}',
              onAction: () => _log(context, ref, ascending),
            );
          }

          final List<MeasurementEntry> descending = ascending.reversed.toList();
          final MeasurementEntry latest = ascending.last;
          final double? monthChange = MeasurementStats.changeOverDays(
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
                      value: '${latest.valueCm.toStringAsFixed(1)} cm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: '30 days', value: _changeLabel(monthChange)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TrendLineChart(
                valuesAscending: [for (final MeasurementEntry e in ascending) e.valueCm],
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
              for (final MeasurementEntry entry in descending)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${entry.valueCm.toStringAsFixed(1)} cm'),
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
    return '$sign${change.toStringAsFixed(1)} cm';
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
