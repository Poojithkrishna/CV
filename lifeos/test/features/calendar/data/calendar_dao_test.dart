import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/calendar/data/repositories/calendar_event_mapper.dart';
import 'package:lifeos/features/calendar/data/repositories/calendar_task_mapper.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_event.dart';
import 'package:lifeos/features/calendar/domain/entities/calendar_task.dart';
import 'package:lifeos/features/calendar/domain/entities/task_priority.dart';

CalendarTask _buildTask({String id = 't1', DateTime? dueDate}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CalendarTask(
    id: id,
    title: 'Task $id',
    dueDate: dueDate,
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
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON;')),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('watchAllTasks orders by dueDate ascending', () async {
    await database.calendarDao.insertTask(
      _buildTask(id: 't2', dueDate: DateTime(2026, 1, 10)).toCompanion(),
    );
    await database.calendarDao.insertTask(
      _buildTask(id: 't1', dueDate: DateTime(2026, 1, 1)).toCompanion(),
    );

    final tasks = await database.calendarDao.watchAllTasks().first;

    expect(tasks.map((row) => row.id), ['t1', 't2']);
  });

  test('toggleTaskDone flips isDone and is idempotent per call', () async {
    await database.calendarDao.insertTask(_buildTask().toCompanion());

    await database.calendarDao.toggleTaskDone('t1');
    CalendarTask task = (await database.calendarDao.watchTask('t1').first)!.toDomain();
    expect(task.isDone, isTrue);

    await database.calendarDao.toggleTaskDone('t1');
    task = (await database.calendarDao.watchTask('t1').first)!.toDomain();
    expect(task.isDone, isFalse);
  });

  test('toggleTaskDone is a no-op for an id that does not exist', () async {
    await database.calendarDao.toggleTaskDone('missing');
    expect(await database.calendarDao.watchTask('missing').first, isNull);
  });

  test('deleteTask removes the row', () async {
    await database.calendarDao.insertTask(_buildTask().toCompanion());
    await database.calendarDao.deleteTask('t1');
    expect(await database.calendarDao.watchTask('t1').first, isNull);
  });

  test('watchAllEvents orders by startTime ascending', () async {
    await database.calendarDao.insertEvent(
      _buildEvent(id: 'e2', startTime: DateTime(2026, 1, 10, 14)).toCompanion(),
    );
    await database.calendarDao.insertEvent(
      _buildEvent(id: 'e1', startTime: DateTime(2026, 1, 1, 9)).toCompanion(),
    );

    final events = await database.calendarDao.watchAllEvents().first;

    expect(events.map((row) => row.id), ['e1', 'e2']);
  });

  test('updateEvent persists a title change', () async {
    await database.calendarDao.insertEvent(
      _buildEvent(startTime: DateTime(2026, 1, 1, 9)).toCompanion(),
    );
    final CalendarEvent stored = (await database.calendarDao.watchEvent('e1').first)!.toDomain();

    await database.calendarDao.updateEvent(stored.copyWith(title: 'Renamed').toCompanion());

    final CalendarEvent updated = (await database.calendarDao.watchEvent('e1').first)!.toDomain();
    expect(updated.title, 'Renamed');
  });

  test('deleteEvent removes the row', () async {
    await database.calendarDao.insertEvent(
      _buildEvent(startTime: DateTime(2026, 1, 1, 9)).toCompanion(),
    );
    await database.calendarDao.deleteEvent('e1');
    expect(await database.calendarDao.watchEvent('e1').first, isNull);
  });
}
