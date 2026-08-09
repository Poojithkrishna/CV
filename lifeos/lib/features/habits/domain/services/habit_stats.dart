import '../entities/habit.dart';
import '../entities/habit_entry.dart';

/// Pure, DB-free streak/completion calculations shared by the habit list
/// and detail screens. Everything here takes already-loaded entries so it
/// stays trivially testable without a database.
class HabitStats {
  HabitStats._();

  static const int _maxLookbackPeriods = 3660;

  /// Consecutive completed periods leading up to (and possibly including)
  /// [asOf]'s period. The current period gets a pass if it isn't complete
  /// yet — it just doesn't count, so an in-progress day/week/month never
  /// breaks a streak before it's actually missed.
  static int currentStreak({
    required Habit habit,
    required Set<DateTime> completedPeriods,
    required DateTime asOf,
  }) {
    DateTime cursor = habit.frequency.periodStart(asOf);
    int streak = 0;
    bool isCurrentPeriod = true;

    for (int i = 0; i < _maxLookbackPeriods; i++) {
      if (habit.isScheduledOn(cursor)) {
        final bool done = completedPeriods.contains(cursor);
        if (done) {
          streak++;
        } else if (!isCurrentPeriod) {
          break;
        }
      }
      isCurrentPeriod = false;
      cursor = habit.frequency.previousPeriodStart(cursor);
    }
    return streak;
  }

  /// The longest run of consecutive completed (scheduled) periods in
  /// [completedPeriods], anywhere in history.
  static int longestStreak({
    required Habit habit,
    required Set<DateTime> completedPeriods,
  }) {
    if (completedPeriods.isEmpty) return 0;

    final List<DateTime> sorted = completedPeriods.toList()..sort();
    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      if (_isNextScheduledPeriod(habit, sorted[i - 1], sorted[i])) {
        current += 1;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
    }
    return longest;
  }

  /// Whether [next] is the very next *scheduled* period after [from]
  /// (skipping any unscheduled custom days in between).
  static bool _isNextScheduledPeriod(Habit habit, DateTime from, DateTime next) {
    DateTime cursor = habit.frequency.nextPeriodStart(from);
    for (int i = 0; i < _maxLookbackPeriods; i++) {
      if (habit.isScheduledOn(cursor)) {
        return cursor == next;
      }
      cursor = habit.frequency.nextPeriodStart(cursor);
    }
    return false;
  }

  /// Fraction of scheduled periods between [from] and [to] (inclusive,
  /// both normalized to period starts) that were completed.
  static double completionRate({
    required Habit habit,
    required Set<DateTime> completedPeriods,
    required DateTime from,
    required DateTime to,
  }) {
    DateTime cursor = habit.frequency.periodStart(from);
    final DateTime end = habit.frequency.periodStart(to);
    int scheduled = 0;
    int completed = 0;

    for (int i = 0; i < _maxLookbackPeriods && !cursor.isAfter(end); i++) {
      if (habit.isScheduledOn(cursor)) {
        scheduled++;
        if (completedPeriods.contains(cursor)) completed++;
      }
      cursor = habit.frequency.nextPeriodStart(cursor);
    }
    return scheduled == 0 ? 0 : completed / scheduled;
  }

  /// A completion ratio (0-1) per period start between [from] and [to],
  /// for rendering a calendar heatmap — partial credit for numeric habit
  /// types (e.g. 3 of a target 5), full/none for checklist and yes/no.
  static Map<DateTime, double> heatmapData({
    required Habit habit,
    required List<HabitEntry> entries,
    required DateTime from,
    required DateTime to,
  }) {
    final Map<DateTime, HabitEntry> byPeriod = {
      for (final HabitEntry entry in entries) entry.periodStart: entry,
    };

    final Map<DateTime, double> result = {};
    DateTime cursor = habit.frequency.periodStart(from);
    final DateTime end = habit.frequency.periodStart(to);

    for (int i = 0; i < _maxLookbackPeriods && !cursor.isAfter(end); i++) {
      final HabitEntry? entry = byPeriod[cursor];
      result[cursor] = _ratioFor(habit, entry);
      cursor = habit.frequency.nextPeriodStart(cursor);
    }
    return result;
  }

  static double _ratioFor(Habit habit, HabitEntry? entry) {
    if (entry == null) return 0;
    if (habit.type.usesChecklistItems) {
      if (habit.checklistItems.isEmpty) return 0;
      return (entry.checkedItemIndices.length / habit.checklistItems.length)
          .clamp(0, 1)
          .toDouble();
    }
    if (habit.targetValue <= 0) return entry.progressValue > 0 ? 1 : 0;
    return (entry.progressValue / habit.targetValue).clamp(0, 1).toDouble();
  }
}
