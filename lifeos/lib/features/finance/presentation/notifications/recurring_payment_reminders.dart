import '../../../../core/notifications/notification_ids.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_payment.dart';

const int _reminderHour = 9;

/// When [payment] should be reminded about. `reminderDaysBefore` doubles
/// as the enabled flag — null means no reminder is configured, and this
/// returns null too. Otherwise, 9 AM, [payment.reminderDaysBefore] days
/// before `nextDueDate`.
DateTime? recurringPaymentReminderTime(RecurringPayment payment) {
  final int? leadDays = payment.reminderDaysBefore;
  if (leadDays == null) return null;
  final DateTime due = payment.nextDueDate;
  return DateTime(due.year, due.month, due.day - leadDays, _reminderHour);
}

/// Schedules or cancels [payment]'s reminder to match
/// [recurringPaymentReminderTime]; re-synced every time "mark as paid"
/// advances the schedule.
Future<void> syncRecurringPaymentReminder(NotificationService service, RecurringPayment payment) async {
  final int id = recurringPaymentReminderId(payment.id);
  final DateTime? reminderTime = recurringPaymentReminderTime(payment);

  if (reminderTime == null) {
    await service.cancel(id);
    return;
  }

  await service.scheduleAt(
    id: id,
    title: 'Bill due soon',
    body: '${payment.name} — ${AppFormatters.currency(payment.amount)} '
        'due ${AppFormatters.shortDate(payment.nextDueDate)}.',
    dateTime: reminderTime,
    payload: 'lifeos://notification/recurring-payment/${payment.id}',
  );
}

/// Cancels [paymentId]'s reminder outright — used on delete, where
/// there's no updated entity left to re-derive the schedule from.
Future<void> cancelRecurringPaymentReminder(NotificationService service, String paymentId) {
  return service.cancel(recurringPaymentReminderId(paymentId));
}
