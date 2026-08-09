import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/exercise_mapper.dart';
import 'package:lifeos/features/fitness/data/repositories/logged_set_mapper.dart';
import 'package:lifeos/features/fitness/data/repositories/workout_session_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/equipment_type.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise.dart';
import 'package:lifeos/features/fitness/domain/entities/logged_set.dart';
import 'package:lifeos/features/fitness/domain/entities/muscle_group.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_session.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    final DateTime now = DateTime(2026, 1, 1);
    await database.exercisesDao.insertExercise(
      Exercise(
        id: 'bench',
        name: 'Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipment: EquipmentType.barbell,
        createdAt: now,
        updatedAt: now,
      ).toCompanion(),
    );
    await database.workoutSessionsDao.startSession(
      WorkoutSession(
        id: 'session-1',
        date: now,
        startTime: now,
        createdAt: now,
        updatedAt: now,
      ).toCompanion(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  LoggedSet buildSet({
    required String id,
    required int reps,
    required double weight,
    bool isWarmup = false,
  }) {
    return LoggedSet(
      id: id,
      sessionId: 'session-1',
      exerciseId: 'bench',
      setNumber: 1,
      reps: reps,
      weight: weight,
      isWarmup: isWarmup,
      completedAt: DateTime(2026, 1, 1),
    );
  }

  test('the first working set logged for an exercise is not a PR', () async {
    final bool isPr = await database.workoutSessionsDao
        .logSet(buildSet(id: 's1', reps: 8, weight: 60).toCompanion());
    expect(isPr, isFalse);
  });

  test('a heavier set than any before it is a new PR', () async {
    await database.workoutSessionsDao.logSet(buildSet(id: 's1', reps: 8, weight: 60).toCompanion());
    final bool isPr = await database.workoutSessionsDao
        .logSet(buildSet(id: 's2', reps: 5, weight: 70).toCompanion());
    expect(isPr, isTrue);
  });

  test('a lighter or equal set is not a PR', () async {
    await database.workoutSessionsDao.logSet(buildSet(id: 's1', reps: 8, weight: 60).toCompanion());
    final bool isPrEqual = await database.workoutSessionsDao
        .logSet(buildSet(id: 's2', reps: 8, weight: 60).toCompanion());
    final bool isPrLighter = await database.workoutSessionsDao
        .logSet(buildSet(id: 's3', reps: 8, weight: 50).toCompanion());
    expect(isPrEqual, isFalse);
    expect(isPrLighter, isFalse);
  });

  test('warmup sets never count as PRs and are ignored for future PR checks', () async {
    final bool warmupIsPr = await database.workoutSessionsDao
        .logSet(buildSet(id: 's1', reps: 10, weight: 100, isWarmup: true).toCompanion());
    expect(warmupIsPr, isFalse);

    // A working set lighter than the warmup should still be a PR, since
    // warmups don't establish a working-weight baseline.
    final bool workingIsPr = await database.workoutSessionsDao
        .logSet(buildSet(id: 's2', reps: 8, weight: 60).toCompanion());
    expect(workingIsPr, isTrue);
  });

  test('watchSessionCount reflects every session ever started', () async {
    expect(await database.workoutSessionsDao.watchSessionCount().first, 1);

    await database.workoutSessionsDao.startSession(
      WorkoutSession(
        id: 'session-2',
        date: DateTime(2026, 1, 2),
        startTime: DateTime(2026, 1, 2),
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
      ).toCompanion(),
    );

    expect(await database.workoutSessionsDao.watchSessionCount().first, 2);
  });

  test('getRecentSetsForExercise returns the most recent set first', () async {
    await database.workoutSessionsDao.logSet(
      buildSet(id: 's1', reps: 8, weight: 60).toCompanion(),
    );
    await database.workoutSessionsDao.logSet(
      LoggedSet(
        id: 's2',
        sessionId: 'session-1',
        exerciseId: 'bench',
        setNumber: 2,
        reps: 6,
        weight: 65,
        completedAt: DateTime(2026, 1, 2),
      ).toCompanion(),
    );

    final recent = await database.workoutSessionsDao.getRecentSetsForExercise('bench');
    expect(recent.first.id, 's2');
  });
}
