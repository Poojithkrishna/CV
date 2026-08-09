import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/calendar_event.dart';

extension CalendarEventRowMapper on CalendarEventRow {
  CalendarEvent toDomain() {
    return CalendarEvent(
      id: id,
      title: title,
      notes: notes,
      location: location,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      reminderEnabled: reminderEnabled,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CalendarEventEntityMapper on CalendarEvent {
  CalendarEventsCompanion toCompanion() {
    return CalendarEventsCompanion.insert(
      id: id,
      title: title,
      notes: Value(notes),
      location: Value(location),
      startTime: startTime,
      endTime: Value(endTime),
      isAllDay: Value(isAllDay),
      reminderEnabled: Value(reminderEnabled),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
