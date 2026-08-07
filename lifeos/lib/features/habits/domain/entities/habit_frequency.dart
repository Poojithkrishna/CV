/// How often a habit resets: each variant defines the period a single
/// [HabitEntry] covers. [custom] still tracks one period per day (like
/// [daily]) but only counts days in a habit's chosen weekdays towards
/// streaks — see `HabitStats`.
enum HabitFrequency {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  custom('Custom days');

  const HabitFrequency(this.label);

  final String label;

  /// Normalizes [date] to the start of the period it falls in.
  DateTime periodStart(DateTime date) {
    final DateTime day = DateTime(date.year, date.month, date.day);
    switch (this) {
      case HabitFrequency.daily:
      case HabitFrequency.custom:
        return day;
      case HabitFrequency.weekly:
        final int daysSinceMonday = day.weekday - DateTime.monday;
        return day.subtract(Duration(days: daysSinceMonday));
      case HabitFrequency.monthly:
        return DateTime(day.year, day.month, 1);
    }
  }

  /// The period immediately before [periodStart] (which must already be
  /// normalized via [periodStart]).
  DateTime previousPeriodStart(DateTime periodStart) {
    switch (this) {
      case HabitFrequency.daily:
      case HabitFrequency.custom:
        return periodStart.subtract(const Duration(days: 1));
      case HabitFrequency.weekly:
        return periodStart.subtract(const Duration(days: 7));
      case HabitFrequency.monthly:
        return periodStart.month == 1
            ? DateTime(periodStart.year - 1, 12, 1)
            : DateTime(periodStart.year, periodStart.month - 1, 1);
    }
  }

  /// The period immediately after [periodStart].
  DateTime nextPeriodStart(DateTime periodStart) {
    switch (this) {
      case HabitFrequency.daily:
      case HabitFrequency.custom:
        return periodStart.add(const Duration(days: 1));
      case HabitFrequency.weekly:
        return periodStart.add(const Duration(days: 7));
      case HabitFrequency.monthly:
        return periodStart.month == 12
            ? DateTime(periodStart.year + 1, 1, 1)
            : DateTime(periodStart.year, periodStart.month + 1, 1);
    }
  }
}
