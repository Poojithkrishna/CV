import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../habits/data/repositories/habit_mapper.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/goal_repository.dart';
import '../daos/goals_dao.dart';
import 'goal_mapper.dart';
import 'milestone_mapper.dart';

class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl(this._dao);

  final GoalsDao _dao;

  @override
  Stream<List<Goal>> watchActiveGoals() {
    return _dao
        .watchActiveGoals()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Goal?> watchGoal(String id) {
    return _dao.watchGoal(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Goal>> createGoal(Goal goal) async {
    try {
      await _dao.insertGoal(goal.toCompanion());
      return Result.ok(goal);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save goal: $e'));
    }
  }

  @override
  Future<Result<Goal>> updateGoal(Goal goal) async {
    try {
      final bool updated = await _dao.updateGoal(goal.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Goal no longer exists.'));
      }
      return Result.ok(goal);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update goal: $e'));
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      await _dao.deleteGoal(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete goal: $e'));
    }
  }

  @override
  Stream<List<Milestone>> watchMilestones(String goalId) {
    return _dao
        .watchMilestonesForGoal(goalId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Milestone>> addMilestone(Milestone milestone) async {
    try {
      await _dao.insertMilestone(milestone.toCompanion());
      return Result.ok(milestone);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not add milestone: $e'));
    }
  }

  @override
  Future<Result<void>> deleteMilestone(String id) async {
    try {
      await _dao.deleteMilestone(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete milestone: $e'));
    }
  }

  @override
  Future<Result<void>> toggleMilestone(String id) async {
    try {
      await _dao.toggleMilestone(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update milestone: $e'));
    }
  }

  @override
  Future<int> nextMilestoneSortOrder(String goalId) {
    return _dao.countMilestonesForGoal(goalId);
  }

  @override
  Stream<List<Habit>> watchLinkedHabits(String goalId) {
    return _dao
        .watchLinkedHabits(goalId)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> linkHabit(String goalId, String habitId) async {
    try {
      await _dao.linkHabit(goalId, habitId);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not link habit: $e'));
    }
  }

  @override
  Future<Result<void>> unlinkHabit(String goalId, String habitId) async {
    try {
      await _dao.unlinkHabit(goalId, habitId);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not unlink habit: $e'));
    }
  }
}
