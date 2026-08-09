import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_task.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../daos/calendar_dao.dart';
import 'calendar_event_mapper.dart';
import 'calendar_task_mapper.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._dao);

  final CalendarDao _dao;

  @override
  Stream<List<CalendarTask>> watchAllTasks() {
    return _dao.watchAllTasks().map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<CalendarTask?> watchTask(String id) {
    return _dao.watchTask(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<CalendarTask>> createTask(CalendarTask task) async {
    try {
      await _dao.insertTask(task.toCompanion());
      return Result.ok(task);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save "${task.title}": $e'));
    }
  }

  @override
  Future<Result<CalendarTask>> updateTask(CalendarTask task) async {
    try {
      await _dao.updateTask(task.toCompanion());
      return Result.ok(task);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update "${task.title}": $e'));
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await _dao.deleteTask(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete task: $e'));
    }
  }

  @override
  Future<Result<void>> toggleTaskDone(String id) async {
    try {
      await _dao.toggleTaskDone(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update task: $e'));
    }
  }

  @override
  Stream<List<CalendarEvent>> watchAllEvents() {
    return _dao.watchAllEvents().map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<CalendarEvent?> watchEvent(String id) {
    return _dao.watchEvent(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<CalendarEvent>> createEvent(CalendarEvent event) async {
    try {
      await _dao.insertEvent(event.toCompanion());
      return Result.ok(event);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save "${event.title}": $e'));
    }
  }

  @override
  Future<Result<CalendarEvent>> updateEvent(CalendarEvent event) async {
    try {
      await _dao.updateEvent(event.toCompanion());
      return Result.ok(event);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update "${event.title}": $e'));
    }
  }

  @override
  Future<Result<void>> deleteEvent(String id) async {
    try {
      await _dao.deleteEvent(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete event: $e'));
    }
  }
}
