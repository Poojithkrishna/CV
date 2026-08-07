/// How often a recurring payment repeats. Each variant knows how to
/// compute its own next occurrence, with month arithmetic clamped to the
/// target month's actual length (e.g. 31 Jan → 28/29 Feb, not 3 Mar).
enum RecurrenceFrequency {
  weekly('Weekly'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  yearly('Yearly');

  const RecurrenceFrequency(this.label);

  final String label;

  DateTime next(DateTime from) {
    return switch (this) {
      RecurrenceFrequency.weekly => from.add(const Duration(days: 7)),
      RecurrenceFrequency.monthly => _addMonths(from, 1),
      RecurrenceFrequency.quarterly => _addMonths(from, 3),
      RecurrenceFrequency.yearly => _addMonths(from, 12),
    };
  }

  static DateTime _addMonths(DateTime date, int months) {
    final int totalMonths = (date.year * 12 + (date.month - 1)) + months;
    final int year = totalMonths ~/ 12;
    final int month = totalMonths % 12 + 1;
    final int day = date.day.clamp(1, _daysInMonth(year, month));
    return DateTime(year, month, day, date.hour, date.minute);
  }

  static int _daysInMonth(int year, int month) {
    final DateTime firstOfNextMonth =
        month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return firstOfNextMonth.subtract(const Duration(days: 1)).day;
  }
}
