import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/entities/plan_exercise.dart';
import '../../domain/services/workout_stats.dart';
import '../providers/exercise_providers.dart';
import '../providers/workout_session_providers.dart';

final Uuid _uuid = Uuid();

/// One exercise's logging surface within a live workout: target (if this
/// came from a plan), previous performance and a suggested weight, the
/// sets already logged this session, and the input row to log another.
class SessionExerciseCard extends ConsumerStatefulWidget {
  const SessionExerciseCard({
    super.key,
    required this.sessionId,
    required this.exerciseId,
    required this.loggedThisSession,
    required this.onSetLogged,
    this.planExercise,
    this.readOnly = false,
  });

  final String sessionId;
  final String exerciseId;
  final PlanExercise? planExercise;
  final List<LoggedSet> loggedThisSession;

  /// Hides the input row — used once a session has ended, when this
  /// becomes a history view rather than something still being logged.
  final bool readOnly;

  /// Called after a non-warmup set is logged, with whether it was a PR
  /// and how long to rest — lets the parent screen own the rest-timer
  /// banner and PR celebration rather than duplicating them per card.
  final void Function(bool isPr, int restSeconds) onSetLogged;

  @override
  ConsumerState<SessionExerciseCard> createState() => _SessionExerciseCardState();
}

class _SessionExerciseCardState extends ConsumerState<SessionExerciseCard> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isWarmup = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _logSet() async {
    final int? reps = int.tryParse(_repsController.text);
    final double? weight = double.tryParse(_weightController.text);
    if (reps == null || weight == null) return;

    setState(() => _isSaving = true);
    final DateTime now = DateTime.now();
    final LoggedSet set = LoggedSet(
      id: _uuid.v4(),
      sessionId: widget.sessionId,
      exerciseId: widget.exerciseId,
      setNumber: widget.loggedThisSession.length + 1,
      reps: reps,
      weight: weight,
      isWarmup: _isWarmup,
      completedAt: now,
    );

    final result = await ref.read(logSetUseCaseProvider).call(set);
    ref.invalidate(lastLoggedSetForExerciseProvider(widget.exerciseId));

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      ok: (logged) {
        if (!logged.isWarmup) {
          widget.onSetLogged(logged.isPr, widget.planExercise?.restSeconds ?? 90);
        }
      },
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Exercise?> exerciseAsync = ref.watch(exerciseByIdProvider(widget.exerciseId));
    final AsyncValue<LoggedSet?> lastSetAsync =
        ref.watch(lastLoggedSetForExerciseProvider(widget.exerciseId));
    final Exercise? exercise = exerciseAsync.valueOrNull;
    final LoggedSet? lastSet = lastSetAsync.valueOrNull;
    final PlanExercise? target = widget.planExercise;

    final double? suggestedWeight = target != null
        ? WorkoutStats.suggestNextWeight(
            previousWeight: lastSet?.weight,
            previousReps: lastSet?.reps,
            targetReps: target.targetReps,
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(exercise?.equipment.icon ?? Icons.fitness_center_rounded, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise?.name ?? 'Loading…',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
            if (target != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Target: ${target.targetSets} × ${target.targetReps}'
                  '${target.targetWeight != null ? ' @ ${target.targetWeight}kg' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                lastSet != null
                    ? 'Last time: ${lastSet.reps} reps @ ${lastSet.weight}kg'
                    : 'No previous data for this exercise yet',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (suggestedWeight != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Suggested: ${suggestedWeight.toStringAsFixed(1)}kg',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            if (widget.loggedThisSession.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final LoggedSet set in widget.loggedThisSession)
                    Chip(
                      avatar: set.isPr
                          ? const Icon(Icons.emoji_events_rounded, size: 16)
                          : null,
                      label: Text(
                        '#${set.setNumber}: ${set.reps}×${set.weight}kg'
                        '${set.isWarmup ? ' (warmup)' : ''}',
                      ),
                    ),
                ],
              ),
            ],
            if (!widget.readOnly) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Reps',
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimalInputFormatters,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isWarmup,
                    onChanged: (value) => setState(() => _isWarmup = value ?? false),
                  ),
                  const Text('Warmup set'),
                  const Spacer(),
                  FilledButton(
                    onPressed: _isSaving ? null : _logSet,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Log set'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
