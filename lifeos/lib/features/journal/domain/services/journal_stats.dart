import '../entities/journal_entry.dart';
import '../entities/journal_entry_type.dart';

/// Pure, DB-free aggregation over already-loaded journal entries — the
/// Journal home hub.
class JournalStats {
  JournalStats._();

  static const int _maxLookbackDays = 3660;

  /// Consecutive days (leading up to, and possibly including, [asOf])
  /// with at least one entry. Today gets a pass if nothing's been
  /// written yet — it just doesn't count, so an entry-less "today" never
  /// breaks a streak before the day is actually over.
  static int currentStreak(List<JournalEntry> entries, {DateTime? asOf}) {
    final Set<DateTime> daysWithEntries = {
      for (final entry in entries) _dateOnly(entry.date),
    };

    DateTime cursor = _dateOnly(asOf ?? DateTime.now());
    int streak = 0;
    bool isFirstDay = true;

    for (int i = 0; i < _maxLookbackDays; i++) {
      final bool hasEntry = daysWithEntries.contains(cursor);
      if (hasEntry) {
        streak++;
      } else if (!isFirstDay) {
        break;
      }
      isFirstDay = false;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static Map<JournalEntryType, int> countByType(List<JournalEntry> entries) {
    final Map<JournalEntryType, int> counts = {
      for (final type in JournalEntryType.values) type: 0,
    };
    for (final JournalEntry entry in entries) {
      counts[entry.type] = (counts[entry.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Average of every logged mood's 1-5 value. Null if nothing has a
  /// mood attached yet.
  static double? averageMood(List<JournalEntry> entries) {
    final List<int> values = [
      for (final entry in entries)
        if (entry.mood != null) entry.mood!.value,
    ];
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
