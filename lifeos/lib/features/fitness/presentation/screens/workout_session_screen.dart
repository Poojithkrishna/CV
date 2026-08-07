import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/entities/plan_exercise.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/services/workout_stats.dart';
import '../providers/workout_plan_providers.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/exercise_picker_field.dart';
import '../widgets/rest_timer_banner.dart';
import '../widgets/session_exercise_card.dart';

/// The live (or, once finished, read-only) workout screen: one
/// [SessionExerciseCard] per exercise — sourced from the plan day if this
/// session came from one, or added ad hoc otherwise — plus a running
/// volume total and a rest timer between working sets.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int? _activeRestSeconds;
  int _restBannerKey = 0;
  final List<String> _adHocExerciseIds = [];

  void _onSetLogged(bool isPr, int restSeconds) {
    if (isPr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PR! 🎉')),
      );
    }
    setState(() {
      _activeRestSeconds = restSeconds;
      _restBannerKey++;
    });
  }

  Future<void> _addAdHocExercise() async {
    String? selectedId;
    final String? chosen = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add exercise'),
          content: ExercisePickerField(
            selectedExerciseId: selectedId,
            onChanged: (value) => setDialogState(() => selectedId = value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedId == null ? null : () => Navigator.of(context).pop(selectedId),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (chosen != null && !_adHocExerciseIds.contains(chosen)) {
      setState(() => _adHocExerciseIds.add(chosen));
    }
  }

  Future<void> _finish(WorkoutSession session) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Finish workout?',
      message: 'This marks the workout complete. You can still view it afterwards.',
      confirmLabel: 'Finish',
      isDestructive: false,
    );
    if (!confirmed) return;

    final result = await ref.read(endWorkoutSessionUseCaseProvider).call(session);
    if (!mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<WorkoutSession?> sessionAsync =
        ref.watch(workoutSessionByIdProvider(widget.sessionId));

    return sessionAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load workout: $error')),
      ),
      data: (WorkoutSession? session) {
        if (session == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Workout not found.')));
        }

        final AsyncValue<List<LoggedSet>> setsAsync =
            ref.watch(setsForSessionProvider(widget.sessionId));

        return Scaffold(
          appBar: AppBar(
            title: Text(session.isInProgress ? 'Workout in progress' : 'Workout summary'),
            actions: [
              if (session.isInProgress)
                TextButton(
                  onPressed: () => _finish(session),
                  child: const Text('Finish'),
                ),
            ],
          ),
          body: setsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Something went wrong: $error')),
            data: (List<LoggedSet> allSets) {
              final Map<String, List<LoggedSet>> byExercise = {};
              for (final LoggedSet set in allSets) {
                (byExercise[set.exerciseId] ??= []).add(set);
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppFormatters.shortDate(session.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Volume: ${WorkoutStats.sessionVolume(allSets).toStringAsFixed(0)}kg',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (_activeRestSeconds != null && session.isInProgress)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: RestTimerBanner(
                        key: ValueKey(_restBannerKey),
                        seconds: _activeRestSeconds!,
                        onDismiss: () => setState(() => _activeRestSeconds = null),
                      ),
                    ),
                  Expanded(
                    child: session.dayId != null
                        ? _PlanDayExercises(
                            session: session,
                            dayId: session.dayId!,
                            setsByExercise: byExercise,
                            onSetLogged: _onSetLogged,
                          )
                        : _AdHocExercises(
                            session: session,
                            adHocExerciseIds: _adHocExerciseIds,
                            setsByExercise: byExercise,
                            onSetLogged: _onSetLogged,
                            onAddExercise: _addAdHocExercise,
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _PlanDayExercises extends ConsumerWidget {
  const _PlanDayExercises({
    required this.session,
    required this.dayId,
    required this.setsByExercise,
    required this.onSetLogged,
  });

  final WorkoutSession session;
  final String dayId;
  final Map<String, List<LoggedSet>> setsByExercise;
  final void Function(bool isPr, int restSeconds) onSetLogged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanExercise>> exercisesAsync = ref.watch(exercisesForDayProvider(dayId));

    return exercisesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Something went wrong: $error')),
      data: (List<PlanExercise> planExercises) {
        if (planExercises.isEmpty) {
          return const Center(child: Text('This day has no exercises to log.'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            for (final PlanExercise planExercise in planExercises)
              SessionExerciseCard(
                sessionId: session.id,
                exerciseId: planExercise.exerciseId,
                planExercise: planExercise,
                loggedThisSession: setsByExercise[planExercise.exerciseId] ?? const [],
                onSetLogged: onSetLogged,
                readOnly: !session.isInProgress,
              ),
          ],
        );
      },
    );
  }
}

class _AdHocExercises extends StatelessWidget {
  const _AdHocExercises({
    required this.session,
    required this.adHocExerciseIds,
    required this.setsByExercise,
    required this.onSetLogged,
    required this.onAddExercise,
  });

  final WorkoutSession session;
  final List<String> adHocExerciseIds;
  final Map<String, List<LoggedSet>> setsByExercise;
  final void Function(bool isPr, int restSeconds) onSetLogged;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final List<String> exerciseIds = {
      ...adHocExerciseIds,
      ...setsByExercise.keys,
    }.toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final String exerciseId in exerciseIds)
          SessionExerciseCard(
            sessionId: session.id,
            exerciseId: exerciseId,
            loggedThisSession: setsByExercise[exerciseId] ?? const [],
            onSetLogged: onSetLogged,
            readOnly: !session.isInProgress,
          ),
        if (session.isInProgress)
          OutlinedButton.icon(
            onPressed: onAddExercise,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add exercise'),
          )
        else if (exerciseIds.isEmpty)
          const Center(child: Text('No exercises were logged in this workout.')),
      ],
    );
  }
}
