import '../../../../core/utils/result.dart';
import '../../../habits/domain/entities/habit.dart';
import '../entities/goal.dart';
import '../entities/milestone.dart';

abstract interface class GoalRepository {
  Stream<List<Goal>> watchActiveGoals();
  Stream<Goal?> watchGoal(String id);

  Future<Result<Goal>> createGoal(Goal goal);
  Future<Result<Goal>> updateGoal(Goal goal);
  Future<Result<void>> deleteGoal(String id);

  Stream<List<Milestone>> watchMilestones(String goalId);
  Future<Result<Milestone>> addMilestone(Milestone milestone);
  Future<Result<void>> deleteMilestone(String id);
  Future<Result<void>> toggleMilestone(String id);
  Future<int> nextMilestoneSortOrder(String goalId);

  Stream<List<Habit>> watchLinkedHabits(String goalId);
  Future<Result<void>> linkHabit(String goalId, String habitId);
  Future<Result<void>> unlinkHabit(String goalId, String habitId);
}
