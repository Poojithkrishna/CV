import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/workout_plan.dart';
import '../providers/workout_plan_providers.dart';
import '../widgets/workout_plan_tile.dart';
import '../../../../app/origin/origin_glyphs.dart';

class WorkoutPlansListScreen extends ConsumerWidget {
  const WorkoutPlansListScreen({super.key});

  Future<void> _setActive(BuildContext context, WidgetRef ref, String planId) async {
    final result = await ref.read(setActivePlanUseCaseProvider).call(planId);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WorkoutPlan>> plansAsync = ref.watch(activePlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Plans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fitness/plans/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Plan'),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<WorkoutPlan> plans) {
          if (plans.isEmpty) {
            return EmptyState(
              icon: Icons.event_note_outlined,
              title: 'No workout plans yet',
              message: 'Create a plan for the gym, home, travel or however you train — '
                  'you can make as many as you want and switch between them instantly.',
              actionLabel: 'Create your first plan',
              onAction: () => context.push('/fitness/plans/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final WorkoutPlan plan = plans[index];
              return WorkoutPlanTile(
                plan: plan,
                onTap: () => context.push('/fitness/plans/${plan.id}'),
                onSetActive: () => _setActive(context, ref, plan.id),
              );
            },
          );
        },
      ),
    );
  }
}
