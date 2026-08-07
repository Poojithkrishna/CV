import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/goals/domain/entities/goal.dart';
import 'package:lifeos/features/goals/domain/entities/milestone.dart';
import 'package:lifeos/features/goals/domain/services/goal_stats.dart';

Goal _buildGoal({double progressValue = 0, double targetValue = 10}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Goal(
    id: 'g1',
    title: 'Run a marathon',
    progressValue: progressValue,
    targetValue: targetValue,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

Milestone _milestone(String id, {bool isCompleted = false}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Milestone(
    id: id,
    goalId: 'g1',
    title: 'Milestone $id',
    isCompleted: isCompleted,
    sortOrder: 0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('GoalStats.progress', () {
    test('uses the fraction of completed milestones when milestones exist', () {
      final goal = _buildGoal();
      final milestones = [
        _milestone('m1', isCompleted: true),
        _milestone('m2', isCompleted: true),
        _milestone('m3'),
        _milestone('m4'),
      ];

      expect(GoalStats.progress(goal, milestones), 0.5);
    });

    test('falls back to progressValue/targetValue with no milestones', () {
      final goal = _buildGoal(progressValue: 3, targetValue: 12);
      expect(GoalStats.progress(goal, const []), closeTo(0.25, 1e-9));
    });

    test('clamps progress at 1 even if progressValue exceeds target', () {
      final goal = _buildGoal(progressValue: 20, targetValue: 10);
      expect(GoalStats.progress(goal, const []), 1);
    });

    test('treats a zero target as complete once any progress is logged', () {
      final goal = _buildGoal(progressValue: 1, targetValue: 0);
      expect(GoalStats.progress(goal, const []), 1);
    });

    test('is zero for a fresh goal with no milestones and no progress', () {
      final goal = _buildGoal(progressValue: 0, targetValue: 10);
      expect(GoalStats.progress(goal, const []), 0);
    });
  });

  group('GoalStats.isCompleted', () {
    test('is true once every milestone is completed', () {
      final goal = _buildGoal();
      final milestones = [_milestone('m1', isCompleted: true)];
      expect(GoalStats.isCompleted(goal, milestones), isTrue);
    });

    test('is false with a mix of completed and pending milestones', () {
      final goal = _buildGoal();
      final milestones = [
        _milestone('m1', isCompleted: true),
        _milestone('m2'),
      ];
      expect(GoalStats.isCompleted(goal, milestones), isFalse);
    });
  });
}
