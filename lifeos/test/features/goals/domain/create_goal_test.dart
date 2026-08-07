import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/goals/domain/entities/goal.dart';
import 'package:lifeos/features/goals/domain/entities/milestone.dart';
import 'package:lifeos/features/goals/domain/repositories/goal_repository.dart';
import 'package:lifeos/features/goals/domain/usecases/add_milestone.dart';
import 'package:lifeos/features/goals/domain/usecases/create_goal.dart';
import 'package:lifeos/features/habits/domain/entities/habit.dart';

class _FakeGoalRepository implements GoalRepository {
  Goal? savedGoal;
  Milestone? savedMilestone;

  @override
  Future<Result<Goal>> createGoal(Goal goal) async {
    savedGoal = goal;
    return Result.ok(goal);
  }

  @override
  Future<Result<void>> deleteGoal(String id) async => const Result.ok(null);

  @override
  Future<Result<Goal>> updateGoal(Goal goal) async => Result.ok(goal);

  @override
  Stream<Goal?> watchGoal(String id) => const Stream.empty();

  @override
  Stream<List<Goal>> watchActiveGoals() => const Stream.empty();

  @override
  Future<Result<Milestone>> addMilestone(Milestone milestone) async {
    savedMilestone = milestone;
    return Result.ok(milestone);
  }

  @override
  Future<Result<void>> deleteMilestone(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> toggleMilestone(String id) async => const Result.ok(null);

  @override
  Future<int> nextMilestoneSortOrder(String goalId) async => 0;

  @override
  Stream<List<Milestone>> watchMilestones(String goalId) => const Stream.empty();

  @override
  Future<Result<void>> linkHabit(String goalId, String habitId) async => const Result.ok(null);

  @override
  Future<Result<void>> unlinkHabit(String goalId, String habitId) async => const Result.ok(null);

  @override
  Stream<List<Habit>> watchLinkedHabits(String goalId) => const Stream.empty();
}

Goal _buildGoal({double targetValue = 10}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Goal(
    id: 'g1',
    title: 'Run a marathon',
    targetValue: targetValue,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

Milestone _buildMilestone({String title = 'First 5k', String goalId = 'g1'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Milestone(
    id: 'm1',
    goalId: goalId,
    title: title,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateGoal', () {
    test('persists a valid goal', () async {
      final repo = _FakeGoalRepository();
      final useCase = CreateGoal(repo);

      final result = await useCase(_buildGoal());

      expect(result.isOk, isTrue);
      expect(repo.savedGoal?.title, 'Run a marathon');
    });

    test('rejects a blank title', () async {
      final repo = _FakeGoalRepository();
      final useCase = CreateGoal(repo);

      final result = await useCase(_buildGoal().copyWith(title: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedGoal, isNull);
    });

    test('rejects a zero target', () async {
      final repo = _FakeGoalRepository();
      final useCase = CreateGoal(repo);

      final result = await useCase(_buildGoal(targetValue: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedGoal, isNull);
    });
  });

  group('AddMilestone', () {
    test('persists a milestone with a non-blank title', () async {
      final repo = _FakeGoalRepository();
      final useCase = AddMilestone(repo);

      final result = await useCase(_buildMilestone());

      expect(result.isOk, isTrue);
      expect(repo.savedMilestone?.title, 'First 5k');
    });

    test('rejects a blank title', () async {
      final repo = _FakeGoalRepository();
      final useCase = AddMilestone(repo);

      final result = await useCase(_buildMilestone(title: '   '));

      expect(result.isErr, isTrue);
      expect(repo.savedMilestone, isNull);
    });
  });
}
