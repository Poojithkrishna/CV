import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/plan_exercise.dart';
import '../providers/exercise_providers.dart';

/// A single exercise entry within a workout day, showing its target
/// sets/reps/weight. Resolves the exercise's name/icon by id since a
/// [PlanExercise] only stores the reference.
class PlanExerciseTile extends ConsumerWidget {
  const PlanExerciseTile({super.key, required this.planExercise, this.onTap, this.onRemove});

  final PlanExercise planExercise;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Exercise?> exerciseAsync =
        ref.watch(exerciseByIdProvider(planExercise.exerciseId));
    final Exercise? exercise = exerciseAsync.valueOrNull;

    final String weightLabel =
        planExercise.targetWeight != null ? ' @ ${planExercise.targetWeight}kg' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Icon(exercise?.equipment.icon ?? Icons.fitness_center_rounded, size: 18),
        ),
        title: Text(exercise?.name ?? 'Loading…'),
        subtitle: Text('${planExercise.targetSets} sets × ${planExercise.targetReps}$weightLabel'),
        trailing: onRemove != null
            ? IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: onRemove)
            : null,
      ),
    );
  }
}
