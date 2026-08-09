import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_session.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_type.dart';
import 'package:lifeos/features/fitness/domain/services/cardio_stats.dart';

CardioSession _session({
  String id = 's1',
  required DateTime date,
  double durationMinutes = 30,
  double? distanceKm,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CardioSession(
    id: id,
    type: CardioType.running,
    date: date,
    durationMinutes: durationMinutes,
    distanceKm: distanceKm,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CardioStats.totalDurationMinutes / totalDistanceKm', () {
    test('sums duration and distance across sessions', () {
      final sessions = [
        _session(id: 's1', date: DateTime(2026, 1, 1), durationMinutes: 30, distanceKm: 5),
        _session(id: 's2', date: DateTime(2026, 1, 2), durationMinutes: 45, distanceKm: 7.5),
      ];

      expect(CardioStats.totalDurationMinutes(sessions), 75);
      expect(CardioStats.totalDistanceKm(sessions), 12.5);
    });

    test('treats a missing distance as zero', () {
      final sessions = [
        _session(id: 's1', date: DateTime(2026, 1, 1), distanceKm: null),
      ];
      expect(CardioStats.totalDistanceKm(sessions), 0);
    });

    test('returns zero for an empty list', () {
      expect(CardioStats.totalDurationMinutes(const []), 0);
      expect(CardioStats.totalDistanceKm(const []), 0);
    });
  });

  group('CardioStats.since', () {
    test('excludes sessions before the cutoff', () {
      final sessions = [
        _session(id: 's1', date: DateTime(2026, 1, 1)),
        _session(id: 's2', date: DateTime(2026, 1, 10)),
      ];

      final recent = CardioStats.since(sessions, DateTime(2026, 1, 5));

      expect(recent.map((s) => s.id), ['s2']);
    });

    test('includes a session exactly on the cutoff date', () {
      final sessions = [_session(id: 's1', date: DateTime(2026, 1, 5))];
      final recent = CardioStats.since(sessions, DateTime(2026, 1, 5));
      expect(recent.map((s) => s.id), ['s1']);
    });
  });
}
