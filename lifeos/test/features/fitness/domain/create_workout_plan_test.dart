import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/plan_exercise.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_day.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_plan.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_plan_type.dart';
import 'package:lifeos/features/fitness/domain/repositories/workout_plan_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/add_exercise_to_day.dart';
import 'package:lifeos/features/fitness/domain/usecases/create_workout_plan.dart';

class _FakeWorkoutPlanRepository implements WorkoutPlanRepository {
  WorkoutPlan? savedPlan;
  PlanExercise? savedPlanExercise;

  @override
  Future<Result<WorkoutPlan>> createPlan(WorkoutPlan plan) async {
    savedPlan = plan;
    return Result.ok(plan);
  }

  @override
  Future<Result<PlanExercise>> addExerciseToDay(PlanExercise planExercise) async {
    savedPlanExercise = planExercise;
    return Result.ok(planExercise);
  }

  @override
  Future<Result<WorkoutDay>> createDay(WorkoutDay day) async => Result.ok(day);

  @override
  Future<Result<void>> deleteDay(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> deletePlan(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> removeExerciseFromDay(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> setActivePlan(String id) async => const Result.ok(null);

  @override
  Future<Result<WorkoutDay>> updateDay(WorkoutDay day) async => Result.ok(day);

  @override
  Future<Result<PlanExercise>> updatePlanExercise(PlanExercise planExercise) async =>
      Result.ok(planExercise);

  @override
  Future<Result<WorkoutPlan>> updatePlan(WorkoutPlan plan) async => Result.ok(plan);

  @override
  Stream<List<WorkoutDay>> watchDaysForPlan(String planId) => const Stream.empty();

  @override
  Stream<List<PlanExercise>> watchExercisesForDay(String dayId) => const Stream.empty();

  @override
  Stream<WorkoutPlan?> watchCurrentActivePlan() => const Stream.empty();

  @override
  Stream<WorkoutPlan?> watchPlan(String id) => const Stream.empty();

  @override
  Stream<List<WorkoutPlan>> watchActivePlans() => const Stream.empty();
}

WorkoutPlan _buildPlan({String name = 'Push Pull Legs'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return WorkoutPlan(
    id: 'plan-1',
    name: name,
    type: WorkoutPlanType.gym,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

PlanExercise _buildPlanExercise({int targetSets = 3, String targetReps = '8-12'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return PlanExercise(
    id: 'pe-1',
    dayId: 'day-1',
    exerciseId: 'exercise-1',
    targetSets: targetSets,
    targetReps: targetReps,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateWorkoutPlan', () {
    test('persists a valid plan', () async {
      final repo = _FakeWorkoutPlanRepository();
      final useCase = CreateWorkoutPlan(repo);

      final result = await useCase(_buildPlan());

      expect(result.isOk, isTrue);
      expect(repo.savedPlan?.name, 'Push Pull Legs');
    });

    test('rejects a blank name', () async {
      final repo = _FakeWorkoutPlanRepository();
      final useCase = CreateWorkoutPlan(repo);

      final result = await useCase(_buildPlan(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedPlan, isNull);
    });
  });

  group('AddExerciseToDay', () {
    test('adds a valid exercise entry', () async {
      final repo = _FakeWorkoutPlanRepository();
      final useCase = AddExerciseToDay(repo);

      final result = await useCase(_buildPlanExercise());

      expect(result.isOk, isTrue);
      expect(repo.savedPlanExercise?.targetSets, 3);
    });

    test('rejects zero target sets', () async {
      final repo = _FakeWorkoutPlanRepository();
      final useCase = AddExerciseToDay(repo);

      final result = await useCase(_buildPlanExercise(targetSets: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedPlanExercise, isNull);
    });

    test('rejects blank target reps', () async {
      final repo = _FakeWorkoutPlanRepository();
      final useCase = AddExerciseToDay(repo);

      final result = await useCase(_buildPlanExercise(targetReps: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedPlanExercise, isNull);
    });
  });
}
