import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/trend_line_chart.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/services/strength_progress_stats.dart';
import '../providers/exercise_providers.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/exercise_picker_field.dart';
import '../../../../app/origin/origin_glyphs.dart';

final Color _accentColor = AppGradients.fitness.colors.first;

class StrengthProgressScreen extends ConsumerStatefulWidget {
  const StrengthProgressScreen({super.key});

  @override
  ConsumerState<StrengthProgressScreen> createState() => _StrengthProgressScreenState();
}

class _StrengthProgressScreenState extends ConsumerState<StrengthProgressScreen> {
  String? _exerciseId;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Exercise>> exercisesAsync = ref.watch(allExercisesProvider);
    final List<Exercise>? exercises = exercisesAsync.valueOrNull;
    final String? exerciseId =
        _exerciseId ?? (exercises != null && exercises.isNotEmpty ? exercises.first.id : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Strength Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExercisePickerField(
              selectedExerciseId: exerciseId,
              onChanged: (value) => setState(() => _exerciseId = value),
            ),
            const SizedBox(height: 20),
            if (exerciseId != null)
              Expanded(child: _ExerciseProgress(exerciseId: exerciseId))
            else
              const Expanded(
                child: EmptyState(
                  glyph: OriginGlyphType.fitness,
                  icon: Icons.show_chart_rounded,
                  title: 'No exercises yet',
                  message: 'Add an exercise to your library to track its progress.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseProgress extends ConsumerWidget {
  const _ExerciseProgress({required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<LoggedSet>> setsAsync = ref.watch(setsForExerciseProvider(exerciseId));

    return setsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Something went wrong: $error')),
      data: (List<LoggedSet> sets) {
        final List<MapEntry<DateTime, double>> trend = StrengthProgressStats.oneRepMaxByDate(sets);
        final List<LoggedSet> prs = StrengthProgressStats.personalRecords(sets);

        if (trend.isEmpty) {
          return const EmptyState(
            glyph: OriginGlyphType.fitness,
            icon: Icons.show_chart_rounded,
            title: 'No sets logged yet',
            message: 'Log a working set for this exercise during a workout to see its trend here.',
          );
        }

        final double current = trend.last.value;
        final double best = trend.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        return ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(label: 'Current est. 1RM', value: '${current.toStringAsFixed(0)} kg'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(label: 'Best est. 1RM', value: '${best.toStringAsFixed(0)} kg'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Estimated 1-rep max over time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TrendLineChart(
              valuesAscending: [for (final e in trend) e.value],
              color: _accentColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Personal records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (prs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No PRs yet for this exercise.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (final LoggedSet set in prs)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B)),
                    title: Text('${set.weight.toStringAsFixed(1)} kg × ${set.reps}'),
                    subtitle: Text(AppFormatters.shortDate(set.completedAt)),
                  ),
                ),
          ],
        );
      },
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
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
