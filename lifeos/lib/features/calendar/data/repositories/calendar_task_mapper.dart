import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/calendar_task.dart';
import '../../domain/entities/task_priority.dart';

extension CalendarTaskRowMapper on CalendarTaskRow {
  CalendarTask toDomain() {
    return CalendarTask(
      id: id,
      title: title,
      notes: notes,
      dueDate: dueDate,
      isTimeBlocked: isTimeBlocked,
      priority: TaskPriority.values.byName(priority),
      isDone: isDone,
      reminderEnabled: reminderEnabled,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CalendarTaskEntityMapper on CalendarTask {
  CalendarTasksCompanion toCompanion() {
    return CalendarTasksCompanion.insert(
      id: id,
      title: title,
      notes: Value(notes),
      dueDate: Value(dueDate),
      isTimeBlocked: Value(isTimeBlocked),
      priority: priority.name,
      isDone: Value(isDone),
      reminderEnabled: Value(reminderEnabled),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
