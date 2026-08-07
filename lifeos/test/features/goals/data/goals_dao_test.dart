import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/goals/data/repositories/goal_mapper.dart';
import 'package:lifeos/features/goals/data/repositories/milestone_mapper.dart';
import 'package:lifeos/features/goals/domain/entities/goal.dart';
import 'package:lifeos/features/goals/domain/entities/milestone.dart';
import 'package:lifeos/features/habits/data/repositories/habit_mapper.dart';
import 'package:lifeos/features/habits/domain/entities/habit.dart';
import 'package:lifeos/features/habits/domain/entities/habit_frequency.dart';
import 'package:lifeos/features/habits/domain/entities/habit_type.dart';

Goal _buildGoal({String id = 'g1'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Goal(
    id: id,
    title: 'Goal $id',
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

Milestone _buildMilestone(String id, String goalId, {int sortOrder = 0}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Milestone(
    id: id,
    goalId: goalId,
    title: 'Milestone $id',
    sortOrder: sortOrder,
    createdAt: now,
    updatedAt: now,
  );
}

Habit _buildHabit(String id) {
  final DateTime now = DateTime(2026, 1, 1);
  return Habit(
    id: id,
    name: 'Habit $id',
    type: HabitType.yesNo,
    frequency: HabitFrequency.daily,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('toggleMilestone flips completion and is idempotent per call', () async {
    await database.goalsDao.insertGoal(_buildGoal().toCompanion());
    await database.goalsDao.insertMilestone(_buildMilestone('m1', 'g1').toCompanion());

    await database.goalsDao.toggleMilestone('m1');
    var milestones = await database.goalsDao.watchMilestonesForGoal('g1').first;
    expect(milestones.single.isCompleted, isTrue);

    await database.goalsDao.toggleMilestone('m1');
    milestones = await database.goalsDao.watchMilestonesForGoal('g1').first;
    expect(milestones.single.isCompleted, isFalse);
  });

  test('countMilestonesForGoal reflects only that goal\'s milestones', () async {
    await database.goalsDao.insertGoal(_buildGoal(id: 'g1').toCompanion());
    await database.goalsDao.insertGoal(_buildGoal(id: 'g2').toCompanion());
    await database.goalsDao.insertMilestone(_buildMilestone('m1', 'g1').toCompanion());
    await database.goalsDao.insertMilestone(_buildMilestone('m2', 'g1').toCompanion());
    await database.goalsDao.insertMilestone(_buildMilestone('m3', 'g2').toCompanion());

    expect(await database.goalsDao.countMilestonesForGoal('g1'), 2);
    expect(await database.goalsDao.countMilestonesForGoal('g2'), 1);
  });

  test('linking and unlinking a habit updates the joined stream', () async {
    await database.goalsDao.insertGoal(_buildGoal().toCompanion());
    await database.habitsDao.insertHabit(_buildHabit('h1').toCompanion());

    await database.goalsDao.linkHabit('g1', 'h1');
    var linked = await database.goalsDao.watchLinkedHabits('g1').first;
    expect(linked.map((h) => h.id), ['h1']);

    await database.goalsDao.unlinkHabit('g1', 'h1');
    linked = await database.goalsDao.watchLinkedHabits('g1').first;
    expect(linked, isEmpty);
  });

  test('deleting a goal cascades to its milestones and habit links', () async {
    await database.goalsDao.insertGoal(_buildGoal().toCompanion());
    await database.goalsDao.insertMilestone(_buildMilestone('m1', 'g1').toCompanion());
    await database.habitsDao.insertHabit(_buildHabit('h1').toCompanion());
    await database.goalsDao.linkHabit('g1', 'h1');

    await database.goalsDao.deleteGoal('g1');

    expect(await database.goalsDao.watchMilestonesForGoal('g1').first, isEmpty);
    expect(await database.goalsDao.watchLinkedHabits('g1').first, isEmpty);
  });
}
