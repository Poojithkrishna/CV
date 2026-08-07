import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_tile.dart';

class HabitsListScreen extends ConsumerWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Habit>> habitsAsync = ref.watch(activeHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habits/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Habit'),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Habit> habits) {
          if (habits.isEmpty) {
            return EmptyState(
              icon: Icons.local_fire_department_outlined,
              title: 'No habits yet',
              message: 'Track anything recurring — yes/no, a counter, a timer, '
                  'a checklist, or something you already do in another module.',
              actionLabel: 'Create your first habit',
              onAction: () => context.push('/habits/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final Habit habit = habits[index];
              return HabitTile(
                habit: habit,
                onTap: () => context.push('/habits/${habit.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
