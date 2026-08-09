import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_event.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_task.dart';
import 'package:lifeos/features/calendar/domain/entities/task_priority.dart';
import 'package:lifeos/features/calendar/domain/services/calendar_stats.dart';

CalendarTask _buildTask({
  String id = 't1',
  DateTime? dueDate,
  bool isDone = false,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarTask(
    id: id,
    title: 'Task $id',
    dueDate: dueDate,
    isDone: isDone,
    priority: TaskPriority.medium,
    colorValue: 0xFF06B6D4,
    createdAt: now,
    updatedAt: now,
  );
}

CalendarEvent _buildEvent({String id = 'e1', required DateTime startTime}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarEvent(
    id: id,
    title: 'Event $id',
    startTime: startTime,
    colorValue: 0xFF06B6D4,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CalendarStats.tasksOnDate', () {
    test('includes only tasks due on that exact day', () {
      final DateTime date = DateTime(2026, 1, 10);
      final tasks = [
        _buildTask(id: 't1', dueDate: DateTime(2026, 1, 10, 9)),
        _buildTask(id: 't2', dueDate: DateTime(2026, 1, 11)),
        _buildTask(id: 't3'),
      ];

      final result = CalendarStats.tasksOnDate(tasks, date);

      expect(result.map((t) => t.id), ['t1']);
    });
  });

  group('CalendarStats.eventsOnDate', () {
    test('includes only events starting on that exact day', () {
      final DateTime date = DateTime(2026, 1, 10);
      final events = [
        _buildEvent(id: 'e1', startTime: DateTime(2026, 1, 10, 14)),
        _buildEvent(id: 'e2', startTime: DateTime(2026, 1, 11, 9)),
      ];

      final result = CalendarStats.eventsOnDate(events, date);

      expect(result.map((e) => e.id), ['e1']);
    });
  });

  group('CalendarStats.pendingCount', () {
    test('counts only undone tasks', () {
      final tasks = [
        _buildTask(id: 't1', isDone: false),
        _buildTask(id: 't2', isDone: true),
        _buildTask(id: 't3', isDone: false),
      ];
      expect(CalendarStats.pendingCount(tasks), 2);
    });
  });

  group('CalendarStats.overdueTasks', () {
    final DateTime today = DateTime(2026, 1, 10);

    test('includes undone tasks due strictly before today', () {
      final tasks = [
        _buildTask(id: 't1', dueDate: DateTime(2026, 1, 5)),
        _buildTask(id: 't2', dueDate: DateTime(2026, 1, 10)),
      ];
      final result = CalendarStats.overdueTasks(tasks, today);
      expect(result.map((t) => t.id), ['t1']);
    });

    test('excludes done tasks even if overdue', () {
      final tasks = [_buildTask(id: 't1', dueDate: DateTime(2026, 1, 5), isDone: true)];
      expect(CalendarStats.overdueTasks(tasks, today), isEmpty);
    });

    test('excludes tasks with no due date', () {
      final tasks = [_buildTask(id: 't1')];
      expect(CalendarStats.overdueTasks(tasks, today), isEmpty);
    });
  });
}
