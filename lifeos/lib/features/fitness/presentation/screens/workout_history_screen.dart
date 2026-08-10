import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/session_history_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkoutSession>> sessionsAsync = ref.watch(recentSessionsProvider(100));

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/workouts/start'),
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Start workout'),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<WorkoutSession> sessions) {
          if (sessions.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.fitness,
              icon: Icons.fitness_center_outlined,
              title: 'No workouts logged yet',
              message: 'Start a workout from a plan, or jump in ad hoc.',
              actionLabel: 'Start a workout',
              onAction: () => context.push('/fitness/workouts/start'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final WorkoutSession session = sessions[index];
              return SessionHistoryTile(
                session: session,
                onTap: () => context.push('/fitness/workouts/${session.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
