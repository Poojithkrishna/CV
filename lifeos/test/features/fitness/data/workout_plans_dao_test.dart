import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/workout_plan_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_plan.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_plan_type.dart';

WorkoutPlan _buildPlan(String id, {bool isActive = false}) {
  final DateTime now = DateTime(2026, 1, 1);
  return WorkoutPlan(
    id: id,
    name: 'Plan $id',
    type: WorkoutPlanType.gym,
    colorValue: 0xFF7C4DFF,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.workoutPlansDao.insertPlan(_buildPlan('a', isActive: true).toCompanion());
    await database.workoutPlansDao.insertPlan(_buildPlan('b').toCompanion());
    await database.workoutPlansDao.insertPlan(_buildPlan('c').toCompanion());
  });

  tearDown(() async {
    await database.close();
  });

  test('only one plan is active at a time after switching', () async {
    await database.workoutPlansDao.setActivePlan('b');

    final plans = await database.workoutPlansDao.watchActivePlans().first;
    final activeCount = plans.where((p) => p.isActive).length;
    expect(activeCount, 1);
    expect(plans.firstWhere((p) => p.id == 'b').isActive, isTrue);
    expect(plans.firstWhere((p) => p.id == 'a').isActive, isFalse);
  });

  test('watchCurrentActivePlan reflects the switch', () async {
    await database.workoutPlansDao.setActivePlan('c');
    final active = await database.workoutPlansDao.watchCurrentActivePlan().first;
    expect(active?.id, 'c');
  });

  test('switching to an already-active plan is a no-op', () async {
    await database.workoutPlansDao.setActivePlan('a');
    final plans = await database.workoutPlansDao.watchActivePlans().first;
    expect(plans.where((p) => p.isActive).length, 1);
    expect(plans.firstWhere((p) => p.id == 'a').isActive, isTrue);
  });
}
