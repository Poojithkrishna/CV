import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_group.dart';
import '../providers/exercise_providers.dart';
import '../widgets/exercise_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  MuscleGroup? _filter;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Exercise>> exercisesAsync =
        ref.watch(exercisesByMuscleGroupProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/exercises/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Exercise'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final MuscleGroup group in MuscleGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(group.label),
                      selected: _filter == group,
                      onSelected: (_) => setState(() => _filter = group),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Something went wrong: $error')),
              data: (List<Exercise> exercises) {
                if (exercises.isEmpty) {
                  return EmptyState(
                    glyph: OriginGlyphType.fitness,
                    icon: Icons.fitness_center_outlined,
                    title: 'No exercises here yet',
                    message: 'Add an exercise to build your library.',
                    actionLabel: 'Add an exercise',
                    onAction: () => context.push('/fitness/exercises/new'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final Exercise exercise = exercises[index];
                    return ExerciseTile(
                      exercise: exercise,
                      onTap: () => context.push('/fitness/exercises/${exercise.id}/edit'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
