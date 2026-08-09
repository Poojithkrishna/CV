import '../../../../core/notifications/notification_actions.dart';
import '../../../../core/notifications/notification_deep_link.dart';
import '../../../../core/notifications/notification_ids.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_task.dart';

const int _defaultReminderHour = 9;
const Duration _eventLeadTime = Duration(minutes: 30);

/// When [task] should be reminded about. A time-blocked task reminds at
/// its exact scheduled hour; a plain due-date task reminds at 9 AM that
/// day. Null once the task is done, disabled, or has no due date — a
/// completed task never nags.
DateTime? taskReminderTime(CalendarTask task) {
  if (!task.reminderEnabled || task.dueDate == null || task.isDone) return null;
  final DateTime due = task.dueDate!;
  return task.isTimeBlocked ? due : DateTime(due.year, due.month, due.day, _defaultReminderHour);
}

/// Schedules or cancels [task]'s reminder to match [taskReminderTime].
Future<void> syncTaskReminder(NotificationService service, CalendarTask task) async {
  final int id = calendarTaskReminderId(task.id);
  final DateTime? reminderTime = taskReminderTime(task);

  if (reminderTime == null) {
    await service.cancel(id);
    return;
  }

  const String title = 'Task due';
  final String body = task.title;

  await service.scheduleAt(
    id: id,
    title: title,
    body: body,
    dateTime: reminderTime,
    payload:
        buildNotificationPayload(type: notificationTypeTask, id: task.id, title: title, body: body)
            .toString(),
    actions: actionsFor(notificationTypeTask),
  );
}

/// Cancels [taskId]'s reminder outright — used on delete, where there's
/// no updated entity left to re-derive the schedule from.
Future<void> cancelTaskReminder(NotificationService service, String taskId) {
  return service.cancel(calendarTaskReminderId(taskId));
}

/// When [event] should be reminded about. A timed event reminds 30
/// minutes before it starts (the same default most calendar apps use);
/// an all-day event reminds at 9 AM on the day itself, since "30
/// minutes before midnight" isn't a useful heads-up. Null if the
/// reminder toggle is off.
DateTime? eventReminderTime(CalendarEvent event) {
  if (!event.reminderEnabled) return null;
  final DateTime start = event.startTime;
  return event.isAllDay
      ? DateTime(start.year, start.month, start.day, _defaultReminderHour)
      : start.subtract(_eventLeadTime);
}

/// Schedules or cancels [event]'s reminder to match [eventReminderTime].
Future<void> syncEventReminder(NotificationService service, CalendarEvent event) async {
  final int id = calendarEventReminderId(event.id);
  final DateTime? reminderTime = eventReminderTime(event);

  if (reminderTime == null) {
    await service.cancel(id);
    return;
  }

  const String title = 'Upcoming event';
  final String body = event.isAllDay
      ? '${event.title} — today'
      : '${event.title} at ${AppFormatters.time(event.startTime)}';

  await service.scheduleAt(
    id: id,
    title: title,
    body: body,
    dateTime: reminderTime,
    payload: buildNotificationPayload(
      type: notificationTypeEvent,
      id: event.id,
      title: title,
      body: body,
    ).toString(),
    actions: actionsFor(notificationTypeEvent),
  );
}

/// Cancels [eventId]'s reminder outright — used on delete, where
/// there's no updated entity left to re-derive the schedule from.
Future<void> cancelEventReminder(NotificationService service, String eventId) {
  return service.cancel(calendarEventReminderId(eventId));
}
