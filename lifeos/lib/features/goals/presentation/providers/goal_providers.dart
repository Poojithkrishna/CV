import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../data/daos/goals_dao.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/usecases/add_milestone.dart';
import '../../domain/usecases/create_goal.dart';
import '../../domain/usecases/delete_goal.dart';
import '../../domain/usecases/delete_milestone.dart';
import '../../domain/usecases/link_habit_to_goal.dart';
import '../../domain/usecases/toggle_milestone.dart';
import '../../domain/usecases/unlink_habit_from_goal.dart';
import '../../domain/usecases/update_goal.dart';

final Provider<GoalsDao> goalsDaoProvider = Provider<GoalsDao>((ref) {
  return GoalsDao(ref.watch(appDatabaseProvider));
});

final Provider<GoalRepository> goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.watch(goalsDaoProvider));
});

final Provider<CreateGoal> createGoalUseCaseProvider = Provider(
  (ref) => CreateGoal(ref.watch(goalRepositoryProvider)),
);
final Provider<UpdateGoal> updateGoalUseCaseProvider = Provider(
  (ref) => UpdateGoal(ref.watch(goalRepositoryProvider)),
);
final Provider<DeleteGoal> deleteGoalUseCaseProvider = Provider(
  (ref) => DeleteGoal(ref.watch(goalRepositoryProvider)),
);
final Provider<AddMilestone> addMilestoneUseCaseProvider = Provider(
  (ref) => AddMilestone(ref.watch(goalRepositoryProvider)),
);
final Provider<DeleteMilestone> deleteMilestoneUseCaseProvider = Provider(
  (ref) => DeleteMilestone(ref.watch(goalRepositoryProvider)),
);
final Provider<ToggleMilestone> toggleMilestoneUseCaseProvider = Provider(
  (ref) => ToggleMilestone(ref.watch(goalRepositoryProvider)),
);
final Provider<LinkHabitToGoal> linkHabitToGoalUseCaseProvider = Provider(
  (ref) => LinkHabitToGoal(ref.watch(goalRepositoryProvider)),
);
final Provider<UnlinkHabitFromGoal> unlinkHabitFromGoalUseCaseProvider = Provider(
  (ref) => UnlinkHabitFromGoal(ref.watch(goalRepositoryProvider)),
);

final StreamProvider<List<Goal>> activeGoalsProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalRepositoryProvider).watchActiveGoals();
});

final StreamProviderFamily<Goal?, String> goalByIdProvider =
    StreamProvider.family<Goal?, String>((ref, id) {
  return ref.watch(goalRepositoryProvider).watchGoal(id);
});

final StreamProviderFamily<List<Milestone>, String> milestonesForGoalProvider =
    StreamProvider.family<List<Milestone>, String>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).watchMilestones(goalId);
});

final StreamProviderFamily<List<Habit>, String> linkedHabitsForGoalProvider =
    StreamProvider.family<List<Habit>, String>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).watchLinkedHabits(goalId);
});
