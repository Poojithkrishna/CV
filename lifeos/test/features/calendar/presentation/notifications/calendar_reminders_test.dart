import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_event.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_task.dart';
import 'package:lifeos/features/calendar/domain/entities/task_priority.dart';
import 'package:lifeos/features/calendar/presentation/notifications/calendar_reminders.dart';

CalendarTask _buildTask({
  DateTime? dueDate,
  bool isTimeBlocked = false,
  bool isDone = false,
  bool reminderEnabled = true,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarTask(
    id: 'task-1',
    title: 'Submit report',
    dueDate: dueDate,
    isTimeBlocked: isTimeBlocked,
    isDone: isDone,
    reminderEnabled: reminderEnabled,
    priority: TaskPriority.medium,
    colorValue: 0xFF06B6D4,
    createdAt: now,
    updatedAt: now,
  );
}

CalendarEvent _buildEvent({
  required DateTime startTime,
  bool isAllDay = false,
  bool reminderEnabled = true,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarEvent(
    id: 'event-1',
    title: 'Team sync',
    startTime: startTime,
    isAllDay: isAllDay,
    reminderEnabled: reminderEnabled,
    colorValue: 0xFF06B6D4,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('taskReminderTime', () {
    test('is the exact due date/time when time-blocked', () {
      final task = _buildTask(dueDate: DateTime(2026, 3, 10, 14, 30), isTimeBlocked: true);
      expect(taskReminderTime(task), DateTime(2026, 3, 10, 14, 30));
    });

    test('is 9 AM on the due date when not time-blocked', () {
      final task = _buildTask(dueDate: DateTime(2026, 3, 10), isTimeBlocked: false);
      expect(taskReminderTime(task), DateTime(2026, 3, 10, 9));
    });

    test('is null once the task is done', () {
      final task = _buildTask(dueDate: DateTime(2026, 3, 10), isDone: true);
      expect(taskReminderTime(task), isNull);
    });

    test('is null when the toggle is off', () {
      final task = _buildTask(dueDate: DateTime(2026, 3, 10), reminderEnabled: false);
      expect(taskReminderTime(task), isNull);
    });

    test('is null with no due date', () {
      final task = _buildTask();
      expect(taskReminderTime(task), isNull);
    });
  });

  group('eventReminderTime', () {
    test('is 30 minutes before a timed event\'s start', () {
      final event = _buildEvent(startTime: DateTime(2026, 3, 10, 14, 30));
      expect(eventReminderTime(event), DateTime(2026, 3, 10, 14, 0));
    });

    test('is 9 AM on the day for an all-day event', () {
      final event = _buildEvent(startTime: DateTime(2026, 3, 10), isAllDay: true);
      expect(eventReminderTime(event), DateTime(2026, 3, 10, 9));
    });

    test('is null when the toggle is off', () {
      final event = _buildEvent(startTime: DateTime(2026, 3, 10, 14, 30), reminderEnabled: false);
      expect(eventReminderTime(event), isNull);
    });
  });
}
