import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/logged_set.dart';
import 'package:lifeos/features/fitness/domain/services/strength_progress_stats.dart';

LoggedSet _set({
  required String id,
  required DateTime completedAt,
  required int reps,
  required double weight,
  bool isWarmup = false,
  bool isPr = false,
}) {
  return LoggedSet(
    id: id,
    sessionId: 'session-1',
    exerciseId: 'exercise-1',
    setNumber: 1,
    reps: reps,
    weight: weight,
    isWarmup: isWarmup,
    isPr: isPr,
    completedAt: completedAt,
  );
}

void main() {
  group('StrengthProgressStats.estimatedOneRepMax', () {
    test('applies the Epley formula', () {
      // 100 * (1 + 5/30) = 116.67
      expect(StrengthProgressStats.estimatedOneRepMax(100, 5), closeTo(116.67, 0.1));
    });

    test('returns the raw weight for zero or negative reps', () {
      expect(StrengthProgressStats.estimatedOneRepMax(100, 0), 100);
      expect(StrengthProgressStats.estimatedOneRepMax(100, -1), 100);
    });
  });

  group('StrengthProgressStats.oneRepMaxByDate', () {
    test('excludes warmup sets', () {
      final sets = [
        _set(id: 's1', completedAt: DateTime(2026, 1, 1), reps: 15, weight: 20, isWarmup: true),
        _set(id: 's2', completedAt: DateTime(2026, 1, 1), reps: 8, weight: 60),
      ];

      final trend = StrengthProgressStats.oneRepMaxByDate(sets);

      expect(trend.length, 1);
      expect(trend.single.value, StrengthProgressStats.estimatedOneRepMax(60, 8));
    });

    test('keeps only the best set per calendar day', () {
      final sets = [
        _set(id: 's1', completedAt: DateTime(2026, 1, 1, 9), reps: 8, weight: 60),
        _set(id: 's2', completedAt: DateTime(2026, 1, 1, 10), reps: 5, weight: 70),
      ];

      final trend = StrengthProgressStats.oneRepMaxByDate(sets);

      expect(trend.length, 1);
      expect(trend.single.value, StrengthProgressStats.estimatedOneRepMax(70, 5));
    });

    test('returns one point per day, sorted oldest first', () {
      final sets = [
        _set(id: 's1', completedAt: DateTime(2026, 1, 10), reps: 8, weight: 60),
        _set(id: 's2', completedAt: DateTime(2026, 1, 1), reps: 8, weight: 50),
      ];

      final trend = StrengthProgressStats.oneRepMaxByDate(sets);

      expect(trend.map((e) => e.key), [DateTime(2026, 1, 1), DateTime(2026, 1, 10)]);
    });
  });

  group('StrengthProgressStats.personalRecords', () {
    test('returns only PR sets, most recent first', () {
      final sets = [
        _set(id: 's1', completedAt: DateTime(2026, 1, 1), reps: 8, weight: 60, isPr: true),
        _set(id: 's2', completedAt: DateTime(2026, 1, 5), reps: 8, weight: 65),
        _set(id: 's3', completedAt: DateTime(2026, 1, 10), reps: 8, weight: 70, isPr: true),
      ];

      final prs = StrengthProgressStats.personalRecords(sets);

      expect(prs.map((s) => s.id), ['s3', 's1']);
    });
  });
}
