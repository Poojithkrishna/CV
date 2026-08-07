import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/logged_set.dart';
import 'package:lifeos/features/fitness/domain/services/workout_stats.dart';

LoggedSet _set({
  required int reps,
  required double weight,
  bool isWarmup = false,
}) {
  return LoggedSet(
    id: 'set-${reps}_$weight',
    sessionId: 's1',
    exerciseId: 'e1',
    setNumber: 1,
    reps: reps,
    weight: weight,
    isWarmup: isWarmup,
    completedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('WorkoutStats.sessionVolume', () {
    test('sums reps times weight across sets', () {
      final sets = [
        _set(reps: 10, weight: 20),
        _set(reps: 8, weight: 25),
      ];
      expect(WorkoutStats.sessionVolume(sets), 10 * 20 + 8 * 25);
    });

    test('excludes warmup sets from the total', () {
      final sets = [
        _set(reps: 15, weight: 10, isWarmup: true),
        _set(reps: 10, weight: 20),
      ];
      expect(WorkoutStats.sessionVolume(sets), 10 * 20);
    });

    test('returns zero for an empty list', () {
      expect(WorkoutStats.sessionVolume(const []), 0);
    });
  });

  group('WorkoutStats.suggestNextWeight', () {
    test('returns null with no previous performance', () {
      final result = WorkoutStats.suggestNextWeight(
        previousWeight: null,
        previousReps: null,
        targetReps: '8-12',
      );
      expect(result, isNull);
    });

    test('suggests a weight increase when previous reps met the target', () {
      final result = WorkoutStats.suggestNextWeight(
        previousWeight: 60,
        previousReps: 12,
        targetReps: '8-12',
        increment: 2.5,
      );
      expect(result, 62.5);
    });

    test('suggests repeating the same weight when target reps were not met', () {
      final result = WorkoutStats.suggestNextWeight(
        previousWeight: 60,
        previousReps: 6,
        targetReps: '8-12',
      );
      expect(result, 60);
    });

    test('parses a single-number target reps string', () {
      final result = WorkoutStats.suggestNextWeight(
        previousWeight: 40,
        previousReps: 10,
        targetReps: '10',
        increment: 5,
      );
      expect(result, 45);
    });
  });
}
