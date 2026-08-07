import '../entities/goal.dart';
import '../entities/milestone.dart';

/// Pure, DB-free progress calculation shared by the goal list and detail
/// screens. When [milestones] is non-empty it takes over entirely — the
/// goal's own [Goal.progressValue] is then just a manual fallback for
/// goals that never grow milestones.
class GoalStats {
  GoalStats._();

  static double progress(Goal goal, List<Milestone> milestones) {
    if (milestones.isNotEmpty) {
      final int completed = milestones.where((m) => m.isCompleted).length;
      return completed / milestones.length;
    }
    if (goal.targetValue <= 0) {
      return goal.progressValue > 0 ? 1 : 0;
    }
    return (goal.progressValue / goal.targetValue).clamp(0, 1).toDouble();
  }

  static bool isCompleted(Goal goal, List<Milestone> milestones) {
    return progress(goal, milestones) >= 1.0;
  }
}
