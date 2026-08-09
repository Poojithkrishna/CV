import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_event.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_task.dart';
import 'package:lifeos/features/calendar/domain/entities/task_priority.dart';
import 'package:lifeos/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:lifeos/features/calendar/domain/usecases/create_event.dart';
import 'package:lifeos/features/calendar/domain/usecases/create_task.dart';
import 'package:lifeos/features/calendar/domain/usecases/toggle_task_done.dart';

class _FakeCalendarRepository implements CalendarRepository {
  CalendarTask? savedTask;
  CalendarEvent? savedEvent;
  String? toggledId;

  @override
  Future<Result<CalendarTask>> createTask(CalendarTask task) async {
    savedTask = task;
    return Result.ok(task);
  }

  @override
  Future<Result<CalendarTask>> updateTask(CalendarTask task) async {
    savedTask = task;
    return Result.ok(task);
  }

  @override
  Future<Result<void>> deleteTask(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> toggleTaskDone(String id) async {
    toggledId = id;
    return const Result.ok(null);
  }

  @override
  Stream<CalendarTask?> watchTask(String id) => const Stream.empty();

  @override
  Stream<List<CalendarTask>> watchAllTasks() => const Stream.empty();

  @override
  Future<Result<CalendarEvent>> createEvent(CalendarEvent event) async {
    savedEvent = event;
    return Result.ok(event);
  }

  @override
  Future<Result<CalendarEvent>> updateEvent(CalendarEvent event) async {
    savedEvent = event;
    return Result.ok(event);
  }

  @override
  Future<Result<void>> deleteEvent(String id) async => const Result.ok(null);

  @override
  Stream<CalendarEvent?> watchEvent(String id) => const Stream.empty();

  @override
  Stream<List<CalendarEvent>> watchAllEvents() => const Stream.empty();
}

CalendarTask _buildTask({String title = 'Buy groceries'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarTask(
    id: 't1',
    title: title,
    priority: TaskPriority.medium,
    colorValue: 0xFF06B6D4,
    createdAt: now,
    updatedAt: now,
  );
}

CalendarEvent _buildEvent({
  String title = 'Team meeting',
  DateTime? startTime,
  DateTime? endTime,
}) {
  final DateTime start = startTime ?? DateTime(2026, 1, 1, 10);
  return CalendarEvent(
    id: 'e1',
    title: title,
    startTime: start,
    endTime: endTime,
    colorValue: 0xFF06B6D4,
    createdAt: start,
    updatedAt: start,
  );
}

void main() {
  group('CreateTask', () {
    test('persists a task with a non-blank title', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateTask(repo);

      final result = await useCase(_buildTask());

      expect(result.isOk, isTrue);
      expect(repo.savedTask?.title, 'Buy groceries');
    });

    test('rejects a blank title', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateTask(repo);

      final result = await useCase(_buildTask(title: '   '));

      expect(result.isErr, isTrue);
      expect(repo.savedTask, isNull);
    });
  });

  group('ToggleTaskDone', () {
    test('forwards the id to the repository', () async {
      final repo = _FakeCalendarRepository();
      final useCase = ToggleTaskDone(repo);

      final result = await useCase('t1');

      expect(result.isOk, isTrue);
      expect(repo.toggledId, 't1');
    });
  });

  group('CreateEvent', () {
    test('persists an event with a non-blank title and valid time range', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateEvent(repo);

      final result = await useCase(_buildEvent(endTime: DateTime(2026, 1, 1, 11)));

      expect(result.isOk, isTrue);
      expect(repo.savedEvent?.title, 'Team meeting');
    });

    test('rejects a blank title', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateEvent(repo);

      final result = await useCase(_buildEvent(title: ''));

      expect(result.isErr, isTrue);
      expect(repo.savedEvent, isNull);
    });

    test('rejects an end time before the start time', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateEvent(repo);
      final event = _buildEvent(
        startTime: DateTime(2026, 1, 1, 10),
        endTime: DateTime(2026, 1, 1, 9),
      );

      final result = await useCase(event);

      expect(result.isErr, isTrue);
      expect(repo.savedEvent, isNull);
    });

    test('accepts an event with no end time', () async {
      final repo = _FakeCalendarRepository();
      final useCase = CreateEvent(repo);

      final result = await useCase(_buildEvent());

      expect(result.isOk, isTrue);
    });
  });
}
