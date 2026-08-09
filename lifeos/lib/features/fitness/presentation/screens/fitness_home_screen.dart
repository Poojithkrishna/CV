import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/workout_session.dart';
import '../providers/workout_plan_providers.dart';
import '../providers/workout_session_providers.dart';
import '../widgets/session_history_tile.dart';

const int _recentSessionsLimit = 5;

/// Entry point for the Fitness module: the active plan (with an instant
/// switch/start action), quick links to Plans/Exercise Library/History,
/// and a peek at recent workouts.
class FitnessHomeScreen extends ConsumerWidget {
  const FitnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WorkoutPlan?> activePlanAsync = ref.watch(currentActivePlanProvider);
    final AsyncValue<WorkoutSession?> inProgressAsync = ref.watch(inProgressSessionProvider);
    final AsyncValue<List<WorkoutSession>> recentAsync =
        ref.watch(recentSessionsProvider(_recentSessionsLimit));

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final WorkoutSession? inProgress = inProgressAsync.valueOrNull;
          if (inProgress != null) {
            context.push('/fitness/workouts/${inProgress.id}');
            return;
          }
          final WorkoutPlan? plan = activePlanAsync.valueOrNull;
          context.push(
            plan != null
                ? '/fitness/workouts/start?planId=${plan.id}'
                : '/fitness/workouts/start',
          );
        },
        icon: Icon(inProgressAsync.valueOrNull != null
            ? Icons.arrow_forward_rounded
            : Icons.play_arrow_rounded),
        label: Text(inProgressAsync.valueOrNull != null ? 'Resume' : 'Start workout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          activePlanAsync.when(
            loading: () => const SizedBox(height: 120),
            error: (_, __) => const SizedBox.shrink(),
            data: (WorkoutPlan? plan) {
              return GradientCard(
                gradient: AppGradients.fitness,
                onTap: () =>
                    plan != null ? context.push('/fitness/plans/${plan.id}') : context.push('/fitness/plans'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE PLAN',
                      style: TextStyle(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan?.name ?? 'No active plan',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (plan != null) ...[
                      const SizedBox(height: 4),
                      Text(plan.type.label, style: const TextStyle(color: Colors.white)),
                    ] else ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Create or pick a plan to see it here.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ToolChip(
                  icon: Icons.event_note_outlined,
                  label: 'Plans',
                  onTap: () => context.push('/fitness/plans'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.fitness_center_outlined,
                  label: 'Exercises',
                  onTap: () => context.push('/fitness/exercises'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () => context.push('/fitness/workouts'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Body Weight',
                  onTap: () => context.push('/fitness/body-weight'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Water',
                  onTap: () => context.push('/fitness/water'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.straighten_rounded,
                  label: 'Measurements',
                  onTap: () => context.push('/fitness/measurements'),
                ),
                const SizedBox(width: 8),
                _ToolChip(
                  icon: Icons.restaurant_outlined,
                  label: 'Nutrition',
                  onTap: () => context.push('/fitness/nutrition'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent workouts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => context.push('/fitness/workouts'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          recentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (List<WorkoutSession> sessions) {
              if (sessions.isEmpty) {
                return EmptyState(
                  icon: Icons.fitness_center_outlined,
                  title: 'No workouts yet',
                  message: 'Start your first workout to see it here.',
                );
              }
              return Column(
                children: [
                  for (final WorkoutSession session in sessions)
                    SessionHistoryTile(
                      session: session,
                      onTap: () => context.push('/fitness/workouts/${session.id}'),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
