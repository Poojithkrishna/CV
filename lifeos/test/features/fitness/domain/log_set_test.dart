import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/logged_set.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_session.dart';
import 'package:lifeos/features/fitness/domain/repositories/workout_session_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/log_set.dart';

class _FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  LoggedSet? saved;

  @override
  Future<Result<LoggedSet>> logSet(LoggedSet loggedSet) async {
    saved = loggedSet;
    return Result.ok(loggedSet);
  }

  @override
  Future<Result<void>> deleteLoggedSet(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> deleteSession(String id) async => const Result.ok(null);

  @override
  Future<Result<WorkoutSession>> endSession(WorkoutSession session) async => Result.ok(session);

  @override
  Future<double?> getMaxWeightForExercise(String exerciseId) async => null;

  @override
  Future<List<LoggedSet>> getRecentSetsForExercise(String exerciseId, {int limit = 10}) async => [];

  @override
  Future<Result<WorkoutSession>> startSession(WorkoutSession session) async => Result.ok(session);

  @override
  Stream<WorkoutSession?> watchInProgressSession() => const Stream.empty();

  @override
  Stream<List<WorkoutSession>> watchRecentSessions({int limit = 20}) => const Stream.empty();

  @override
  Stream<WorkoutSession?> watchSession(String id) => const Stream.empty();

  @override
  Stream<List<LoggedSet>> watchSetsForSession(String sessionId) => const Stream.empty();
}

LoggedSet _buildSet({int reps = 8, double weight = 60}) {
  return LoggedSet(
    id: 'set-1',
    sessionId: 'session-1',
    exerciseId: 'exercise-1',
    setNumber: 1,
    reps: reps,
    weight: weight,
    completedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('LogSet', () {
    test('logs a valid set', () async {
      final repo = _FakeWorkoutSessionRepository();
      final useCase = LogSet(repo);

      final result = await useCase(_buildSet());

      expect(result.isOk, isTrue);
      expect(repo.saved?.reps, 8);
    });

    test('rejects zero or negative reps', () async {
      final repo = _FakeWorkoutSessionRepository();
      final useCase = LogSet(repo);

      final result = await useCase(_buildSet(reps: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects negative weight', () async {
      final repo = _FakeWorkoutSessionRepository();
      final useCase = LogSet(repo);

      final result = await useCase(_buildSet(weight: -5));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('allows zero weight for bodyweight exercises', () async {
      final repo = _FakeWorkoutSessionRepository();
      final useCase = LogSet(repo);

      final result = await useCase(_buildSet(weight: 0));

      expect(result.isOk, isTrue);
    });
  });
}
