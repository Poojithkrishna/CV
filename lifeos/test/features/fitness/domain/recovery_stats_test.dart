import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/recovery_entry.dart';
import 'package:lifeos/features/fitness/domain/services/recovery_stats.dart';

RecoveryEntry _entry({double? sleepHours, int? sorenessLevel, int? stressLevel}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecoveryEntry(
    id: 'e1',
    date: now,
    sleepHours: sleepHours,
    sorenessLevel: sorenessLevel,
    stressLevel: stressLevel,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('RecoveryStats.score', () {
    test('returns null when nothing was logged', () {
      expect(RecoveryStats.score(_entry()), isNull);
    });

    test('scores full 8 hours of sleep as a perfect sleep component', () {
      final score = RecoveryStats.score(_entry(sleepHours: 8));
      expect(score, 100);
    });

    test('caps the sleep component at 100 for more than 8 hours', () {
      final score = RecoveryStats.score(_entry(sleepHours: 10));
      expect(score, 100);
    });

    test('scores minimal soreness/stress as high and maximal as low', () {
      final bestCase = RecoveryStats.score(_entry(sorenessLevel: 1, stressLevel: 1));
      final worstCase = RecoveryStats.score(_entry(sorenessLevel: 5, stressLevel: 5));

      expect(bestCase, 100);
      expect(worstCase, 0);
    });

    test('averages only the components that were actually logged', () {
      final score = RecoveryStats.score(_entry(sorenessLevel: 1));
      expect(score, 100);
    });

    test('averages sleep, soreness and stress together when all three are logged', () {
      final score = RecoveryStats.score(
        _entry(sleepHours: 8, sorenessLevel: 1, stressLevel: 5),
      );
      // sleep=100, soreness=100, stress=0 -> average 66.67
      expect(score, closeTo(66.67, 0.1));
    });
  });
}
