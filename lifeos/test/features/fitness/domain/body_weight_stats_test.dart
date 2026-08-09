import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/body_weight_entry.dart';
import 'package:lifeos/features/fitness/domain/services/body_weight_stats.dart';

BodyWeightEntry _entry(DateTime date, double weightKg) {
  return BodyWeightEntry(
    id: 'e-${date.toIso8601String()}',
    date: date,
    weightKg: weightKg,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  group('BodyWeightStats.changeOverDays', () {
    test('returns null with fewer than two entries', () {
      final entries = [_entry(DateTime(2026, 1, 1), 80)];
      final change = BodyWeightStats.changeOverDays(
        entriesAscending: entries,
        days: 7,
        asOf: DateTime(2026, 1, 5),
      );
      expect(change, isNull);
    });

    test('computes the difference from the closest entry at or before the cutoff', () {
      final entries = [
        _entry(DateTime(2026, 1, 1), 82),
        _entry(DateTime(2026, 1, 5), 81),
        _entry(DateTime(2026, 1, 10), 79.5),
      ];
      final change = BodyWeightStats.changeOverDays(
        entriesAscending: entries,
        days: 7,
        asOf: DateTime(2026, 1, 10),
      );
      // cutoff = Jan 3; closest entry at/before cutoff is Jan 1 (82).
      expect(change, closeTo(79.5 - 82, 1e-9));
    });

    test('falls back to the first entry as baseline when nothing is before the cutoff', () {
      final entries = [
        _entry(DateTime(2026, 1, 1), 80),
        _entry(DateTime(2026, 1, 2), 79.8),
      ];
      final change = BodyWeightStats.changeOverDays(
        entriesAscending: entries,
        days: 30,
        asOf: DateTime(2026, 1, 2),
      );
      // cutoff = Dec 3 2025 — every entry is after it, so the baseline
      // stays the very first entry (Jan 1) rather than matching nothing.
      expect(change, closeTo(79.8 - 80, 1e-9));
    });
  });
}
