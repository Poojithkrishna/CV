import 'package:flutter/foundation.dart';

import 'task_priority.dart';

/// A to-do item — optionally due on a specific day, and optionally
/// "time-blocked" onto a specific hour of that day rather than just
/// sitting in an unscheduled list.
@immutable
class CalendarTask {
  const CalendarTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.dueDate,
    this.isTimeBlocked = false,
    this.isDone = false,
    this.reminderEnabled = false,
  });

  final String id;
  final String title;
  final String? notes;

  /// Null means "someday" — no due date yet. When [isTimeBlocked] is
  /// true, this also carries the specific hour/minute the task is
  /// blocked onto; otherwise only the date portion matters.
  final DateTime? dueDate;

  final bool isTimeBlocked;
  final TaskPriority priority;
  final bool isDone;
  final bool reminderEnabled;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarTask copyWith({
    String? title,
    String? notes,
    bool clearNotes = false,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isTimeBlocked,
    TaskPriority? priority,
    bool? isDone,
    bool? reminderEnabled,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return CalendarTask(
      id: id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isTimeBlocked: isTimeBlocked ?? this.isTimeBlocked,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is CalendarTask && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
