import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../habits/data/tables/habits_table.dart';
import '../tables/goal_habit_links_table.dart';
import '../tables/goals_table.dart';
import '../tables/milestones_table.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [Goals, Milestones, GoalHabitLinks, Habits])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  // --- Goals ---

  Stream<List<GoalRow>> watchActiveGoals() {
    return (select(goals)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]))
        .watch();
  }

  Stream<GoalRow?> watchGoal(String id) {
    return (select(goals)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertGoal(GoalsCompanion entry) {
    return into(goals).insert(entry);
  }

  Future<bool> updateGoal(GoalsCompanion entry) {
    return update(goals).replace(entry);
  }

  Future<int> deleteGoal(String id) {
    return (delete(goals)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Milestones ---

  Stream<List<MilestoneRow>> watchMilestonesForGoal(String goalId) {
    return (select(milestones)
          ..where((tbl) => tbl.goalId.equals(goalId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Future<int> countMilestonesForGoal(String goalId) {
    return (select(milestones)..where((tbl) => tbl.goalId.equals(goalId)))
        .get()
        .then((rows) => rows.length);
  }

  Future<void> insertMilestone(MilestonesCompanion entry) {
    return into(milestones).insert(entry);
  }

  Future<int> deleteMilestone(String id) {
    return (delete(milestones)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Flips [id]'s completion flag — read-then-write inside a transaction
  /// so two rapid taps can't race each other to a stale value.
  Future<void> toggleMilestone(String id) {
    return transaction(() async {
      final MilestoneRow? existing =
          await (select(milestones)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (existing == null) return;
      await (update(milestones)..where((tbl) => tbl.id.equals(id))).write(
        MilestonesCompanion(
          isCompleted: Value(!existing.isCompleted),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // --- Linked habits ---

  Stream<List<HabitRow>> watchLinkedHabits(String goalId) {
    final query = select(habits).join([
      innerJoin(goalHabitLinks, goalHabitLinks.habitId.equalsExp(habits.id)),
    ])
      ..where(goalHabitLinks.goalId.equals(goalId));
    return query.watch().map(
          (rows) => rows.map((row) => row.readTable(habits)).toList(growable: false),
        );
  }

  Future<void> linkHabit(String goalId, String habitId) {
    return into(goalHabitLinks).insertOnConflictUpdate(
      GoalHabitLinksCompanion.insert(
        goalId: goalId,
        habitId: habitId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<int> unlinkHabit(String goalId, String habitId) {
    return (delete(goalHabitLinks)
          ..where((tbl) => tbl.goalId.equals(goalId) & tbl.habitId.equals(habitId)))
        .go();
  }
}
