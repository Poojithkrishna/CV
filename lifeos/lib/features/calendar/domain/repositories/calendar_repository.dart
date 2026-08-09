import '../../../../core/utils/result.dart';
import '../entities/calendar_event.dart';
import '../entities/calendar_task.dart';

abstract interface class CalendarRepository {
  Stream<List<CalendarTask>> watchAllTasks();
  Stream<CalendarTask?> watchTask(String id);
  Future<Result<CalendarTask>> createTask(CalendarTask task);
  Future<Result<CalendarTask>> updateTask(CalendarTask task);
  Future<Result<void>> deleteTask(String id);
  Future<Result<void>> toggleTaskDone(String id);

  Stream<List<CalendarEvent>> watchAllEvents();
  Stream<CalendarEvent?> watchEvent(String id);
  Future<Result<CalendarEvent>> createEvent(CalendarEvent event);
  Future<Result<CalendarEvent>> updateEvent(CalendarEvent event);
  Future<Result<void>> deleteEvent(String id);
}
