import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/calendar_events_table.dart';
import '../tables/calendar_tasks_table.dart';

part 'calendar_dao.g.dart';

@DriftAccessor(tables: [CalendarTasks, CalendarEvents])
class CalendarDao extends DatabaseAccessor<AppDatabase> with _$CalendarDaoMixin {
  CalendarDao(super.db);

  // --- Tasks ---

  Stream<List<CalendarTaskRow>> watchAllTasks() {
    return (select(calendarTasks)..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)])).watch();
  }

  Stream<CalendarTaskRow?> watchTask(String id) {
    return (select(calendarTasks)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertTask(CalendarTasksCompanion entry) {
    return into(calendarTasks).insert(entry);
  }

  Future<bool> updateTask(CalendarTasksCompanion entry) {
    return update(calendarTasks).replace(entry);
  }

  Future<int> deleteTask(String id) {
    return (delete(calendarTasks)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> toggleTaskDone(String id) {
    return transaction(() async {
      final CalendarTaskRow? existing =
          await (select(calendarTasks)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (existing == null) return;
      await (update(calendarTasks)..where((tbl) => tbl.id.equals(id))).write(
        CalendarTasksCompanion(
          isDone: Value(!existing.isDone),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // --- Events ---

  Stream<List<CalendarEventRow>> watchAllEvents() {
    return (select(calendarEvents)..orderBy([(tbl) => OrderingTerm.asc(tbl.startTime)])).watch();
  }

  Stream<CalendarEventRow?> watchEvent(String id) {
    return (select(calendarEvents)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertEvent(CalendarEventsCompanion entry) {
    return into(calendarEvents).insert(entry);
  }

  Future<bool> updateEvent(CalendarEventsCompanion entry) {
    return update(calendarEvents).replace(entry);
  }

  Future<int> deleteEvent(String id) {
    return (delete(calendarEvents)..where((tbl) => tbl.id.equals(id))).go();
  }
}
