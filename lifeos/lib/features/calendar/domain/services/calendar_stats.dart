import '../entities/calendar_event.dart';
import '../entities/calendar_task.dart';

/// Pure, DB-free filtering over already-loaded tasks/events — the
/// Calendar home hub and day planner.
class CalendarStats {
  CalendarStats._();

  static List<CalendarTask> tasksOnDate(List<CalendarTask> tasks, DateTime date) {
    return tasks.where((task) => task.dueDate != null && _isSameDay(task.dueDate!, date)).toList(
          growable: false,
        );
  }

  static List<CalendarEvent> eventsOnDate(List<CalendarEvent> events, DateTime date) {
    return events.where((event) => _isSameDay(event.startTime, date)).toList(growable: false);
  }

  static int pendingCount(List<CalendarTask> tasks) {
    return tasks.where((task) => !task.isDone).length;
  }

  /// Undone tasks whose `dueDate` is strictly before [asOf]'s day.
  static List<CalendarTask> overdueTasks(List<CalendarTask> tasks, DateTime asOf) {
    final DateTime today = DateTime(asOf.year, asOf.month, asOf.day);
    return tasks
        .where((task) => !task.isDone && task.dueDate != null && _dateOnly(task.dueDate!).isBefore(today))
        .toList(growable: false);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
