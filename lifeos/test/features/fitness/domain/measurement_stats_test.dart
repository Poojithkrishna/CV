import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/measurement_entry.dart';
import 'package:lifeos/features/fitness/domain/entities/measurement_type.dart';
import 'package:lifeos/features/fitness/domain/services/measurement_stats.dart';

MeasurementEntry _entry(DateTime date, double valueCm) {
  return MeasurementEntry(
    id: 'e-${date.toIso8601String()}',
    type: MeasurementType.waist,
    date: date,
    valueCm: valueCm,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  group('MeasurementStats.changeOverDays', () {
    test('returns null with fewer than two entries', () {
      final entries = [_entry(DateTime(2026, 1, 1), 82)];
      final change = MeasurementStats.changeOverDays(
        entriesAscending: entries,
        days: 30,
        asOf: DateTime(2026, 1, 15),
      );
      expect(change, isNull);
    });

    test('computes the difference from the closest entry at or before the cutoff', () {
      final entries = [
        _entry(DateTime(2026, 1, 1), 84),
        _entry(DateTime(2026, 2, 1), 82),
        _entry(DateTime(2026, 3, 1), 80),
      ];
      final change = MeasurementStats.changeOverDays(
        entriesAscending: entries,
        days: 30,
        asOf: DateTime(2026, 3, 1),
      );
      // cutoff = Jan 30 — closest entry at/before it is Jan 1 (84).
      expect(change, closeTo(80 - 84, 1e-9));
    });

    test('reports a positive change when the measurement increased', () {
      final entries = [
        _entry(DateTime(2026, 1, 1), 30),
        _entry(DateTime(2026, 2, 1), 32),
      ];
      final change = MeasurementStats.changeOverDays(
        entriesAscending: entries,
        days: 30,
        asOf: DateTime(2026, 2, 1),
      );
      expect(change, closeTo(2, 1e-9));
    });
  });
}
