import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry_type.dart';
import 'package:lifeos/features/journal/domain/entities/mood.dart';
import 'package:lifeos/features/journal/domain/services/journal_stats.dart';

JournalEntry _buildEntry({
  String id = 'e1',
  required DateTime date,
  JournalEntryType type = JournalEntryType.freeWriting,
  Mood? mood,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return JournalEntry(
    id: id,
    type: type,
    date: date,
    content: 'Some thoughts',
    mood: mood,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('JournalStats.currentStreak', () {
    final DateTime today = DateTime(2026, 1, 10);

    test('is zero with no entries', () {
      expect(JournalStats.currentStreak(const [], asOf: today), 0);
    });

    test('is one with only a today entry', () {
      final entries = [_buildEntry(date: today)];
      expect(JournalStats.currentStreak(entries, asOf: today), 1);
    });

    test('counts consecutive days including today', () {
      final entries = [
        _buildEntry(id: 'e1', date: today),
        _buildEntry(id: 'e2', date: today.subtract(const Duration(days: 1))),
        _buildEntry(id: 'e3', date: today.subtract(const Duration(days: 2))),
      ];
      expect(JournalStats.currentStreak(entries, asOf: today), 3);
    });

    test('gives today a pass if nothing is written yet', () {
      final entries = [_buildEntry(date: today.subtract(const Duration(days: 1)))];
      expect(JournalStats.currentStreak(entries, asOf: today), 1);
    });

    test('breaks once a prior day (not today) has no entry', () {
      final entries = [_buildEntry(date: today.subtract(const Duration(days: 2)))];
      expect(JournalStats.currentStreak(entries, asOf: today), 0);
    });

    test('counts multiple same-day entries as a single streak day', () {
      final entries = [
        _buildEntry(id: 'e1', date: today, type: JournalEntryType.morning),
        _buildEntry(id: 'e2', date: today, type: JournalEntryType.night),
      ];
      expect(JournalStats.currentStreak(entries, asOf: today), 1);
    });
  });

  group('JournalStats.countByType', () {
    test('counts every type, including zero-count ones', () {
      final DateTime date = DateTime(2026, 1, 1);
      final entries = [
        _buildEntry(id: 'e1', date: date, type: JournalEntryType.morning),
        _buildEntry(id: 'e2', date: date, type: JournalEntryType.morning),
        _buildEntry(id: 'e3', date: date, type: JournalEntryType.gratitude),
      ];

      final counts = JournalStats.countByType(entries);

      expect(counts[JournalEntryType.morning], 2);
      expect(counts[JournalEntryType.gratitude], 1);
      expect(counts[JournalEntryType.night], 0);
      expect(counts.length, JournalEntryType.values.length);
    });
  });

  group('JournalStats.averageMood', () {
    test('averages only entries with a mood logged', () {
      final DateTime date = DateTime(2026, 1, 1);
      final entries = [
        _buildEntry(id: 'e1', date: date, mood: Mood.good),
        _buildEntry(id: 'e2', date: date, mood: Mood.bad),
        _buildEntry(id: 'e3', date: date),
      ];
      expect(JournalStats.averageMood(entries), 3);
    });

    test('is null when nothing has a mood logged', () {
      final entries = [_buildEntry(date: DateTime(2026, 1, 1))];
      expect(JournalStats.averageMood(entries), isNull);
    });
  });
}
