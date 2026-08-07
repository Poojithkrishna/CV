import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exercise.dart';
import '../providers/exercise_providers.dart';

/// Dropdown over the whole exercise library, used when adding an
/// exercise to a workout day.
class ExercisePickerField extends ConsumerWidget {
  const ExercisePickerField({
    super.key,
    required this.selectedExerciseId,
    required this.onChanged,
  });

  final String? selectedExerciseId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Exercise>> exercisesAsync = ref.watch(allExercisesProvider);

    return exercisesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Could not load exercises: $error'),
      data: (List<Exercise> exercises) {
        final bool hasSelected = exercises.any((e) => e.id == selectedExerciseId);
        return DropdownButtonFormField<String>(
          value: hasSelected ? selectedExerciseId : null,
          decoration: const InputDecoration(
            labelText: 'Exercise',
            prefixIcon: Icon(Icons.fitness_center_outlined),
          ),
          isExpanded: true,
          items: [
            for (final Exercise exercise in exercises)
              DropdownMenuItem(
                value: exercise.id,
                child: Text('${exercise.name} · ${exercise.muscleGroup.label}'),
              ),
          ],
          onChanged: onChanged,
          validator: (value) => value == null ? 'Choose an exercise' : null,
        );
      },
    );
  }
}
