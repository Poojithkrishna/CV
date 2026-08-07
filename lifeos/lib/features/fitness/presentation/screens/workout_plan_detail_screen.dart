import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/text_input_dialog.dart';
import '../../domain/entities/plan_exercise.dart';
import '../../domain/entities/workout_day.dart';
import '../../domain/entities/workout_plan.dart';
import '../providers/workout_plan_providers.dart';
import '../widgets/plan_exercise_tile.dart';

final Uuid _uuid = Uuid();

class WorkoutPlanDetailScreen extends ConsumerWidget {
  const WorkoutPlanDetailScreen({super.key, required this.planId});

  final String planId;

  Future<void> _setActive(BuildContext context, WidgetRef ref) async {
    await ref.read(setActivePlanUseCaseProvider).call(planId);
  }

  Future<void> _addDay(BuildContext context, WidgetRef ref, int nextSortOrder) async {
    final String? name = await showTextInputDialog(
      context,
      title: 'New day',
      label: 'Day name (e.g. Push Day)',
    );
    if (name == null) return;

    final DateTime now = DateTime.now();
    final WorkoutDay day = WorkoutDay(
      id: _uuid.v4(),
      planId: planId,
      name: name,
      sortOrder: nextSortOrder,
      createdAt: now,
      updatedAt: now,
    );
    final result = await ref.read(createWorkoutDayUseCaseProvider).call(day);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _deleteDay(BuildContext context, WidgetRef ref, String dayId) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete day?',
      message: 'This removes the day and every exercise entry in it.',
    );
    if (!confirmed) return;
    await ref.read(deleteWorkoutDayUseCaseProvider).call(dayId);
  }

  Future<void> _removeExercise(BuildContext context, WidgetRef ref, String planExerciseId) async {
    await ref.read(removeExerciseFromDayUseCaseProvider).call(planExerciseId);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete plan?',
      message: 'This permanently removes the plan, its days and their exercise entries.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteWorkoutPlanUseCaseProvider).call(planId);
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
    final AsyncValue<WorkoutPlan?> planAsync = ref.watch(workoutPlanByIdProvider(planId));

    return planAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Could not load plan: $error')),
      ),
      data: (WorkoutPlan? plan) {
        if (plan == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Plan not found.')));
        }

        final Color color = Color(plan.colorValue);
        final AsyncValue<List<WorkoutDay>> daysAsync = ref.watch(daysForPlanProvider(planId));

        return Scaffold(
          appBar: AppBar(
            title: Text(plan.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/fitness/plans/${plan.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/fitness/workouts/start?planId=${plan.id}'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start workout'),
          ),
          body: daysAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Something went wrong: $error')),
            data: (List<WorkoutDay> days) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, Color.lerp(color, Colors.black, 0.35)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(plan.type.icon, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plan.type.label,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (plan.isActive)
                          const Chip(
                            label: Text('Active'),
                            backgroundColor: Colors.white24,
                            labelStyle: TextStyle(color: Colors.white),
                            side: BorderSide.none,
                          )
                        else
                          FilledButton.tonal(
                            onPressed: () => _setActive(context, ref),
                            child: const Text('Set active'),
                          ),
                      ],
                    ),
                  ),
                  if (plan.notes != null) ...[
                    const SizedBox(height: 16),
                    Text(plan.notes!),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: () => _addDay(context, ref, days.length),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add day'),
                      ),
                    ],
                  ),
                  if (days.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Add a day (e.g. "Push Day", "Day 1") to start listing exercises.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  else
                    for (final WorkoutDay day in days)
                      _DaySection(
                        day: day,
                        onDeleteDay: () => _deleteDay(context, ref, day.id),
                        onRemoveExercise: (id) => _removeExercise(context, ref, id),
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

class _DaySection extends ConsumerWidget {
  const _DaySection({
    required this.day,
    required this.onDeleteDay,
    required this.onRemoveExercise,
  });

  final WorkoutDay day;
  final VoidCallback onDeleteDay;
  final ValueChanged<String> onRemoveExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlanExercise>> exercisesAsync =
        ref.watch(exercisesForDayProvider(day.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(day.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDeleteDay,
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
        children: [
          exercisesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Something went wrong: $error'),
            ),
            data: (List<PlanExercise> exercises) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    for (final PlanExercise planExercise in exercises)
                      PlanExerciseTile(
                        planExercise: planExercise,
                        onTap: () => context.push(
                          '/fitness/days/${day.id}/exercises/${planExercise.id}/edit',
                          extra: planExercise,
                        ),
                        onRemove: () => onRemoveExercise(planExercise.id),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => context.push('/fitness/days/${day.id}/exercises/new'),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add exercise'),
                        ),
                        if (exercises.isNotEmpty)
                          FilledButton.tonalIcon(
                            onPressed: () => context.push(
                              '/fitness/workouts/start?planId=${day.planId}&dayId=${day.id}',
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('Start'),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
