import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_tile.dart';

class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Goal>> goalsAsync = ref.watch(activeGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Goal'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Goal> goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'No goals yet',
              message: 'Set a target, break it into milestones, and link the '
                  'habits that move you toward it.',
              actionLabel: 'Create your first goal',
              onAction: () => context.push('/goals/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final Goal goal = goals[index];
              return GoalTile(
                goal: goal,
                onTap: () => context.push('/goals/${goal.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
