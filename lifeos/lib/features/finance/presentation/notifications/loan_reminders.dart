import '../../../../core/notifications/notification_actions.dart';
import '../../../../core/notifications/notification_deep_link.dart';
import '../../../../core/notifications/notification_ids.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/loan.dart';

const int _reminderLeadDays = 1;
const int _reminderHour = 9;

/// When [loan] should be reminded about — a fixed 1 day before its due
/// date at 9 AM, since Loan has no per-loan configurable lead time, just
/// the on/off `reminderEnabled` toggle. Null once the loan is settled,
/// has no due date, or the toggle is off, so a paid-off loan never nags.
DateTime? loanReminderTime(Loan loan) {
  if (!loan.reminderEnabled || loan.dueDate == null || loan.isSettled) return null;
  final DateTime due = loan.dueDate!;
  return DateTime(due.year, due.month, due.day - _reminderLeadDays, _reminderHour);
}

/// Schedules or cancels [loan]'s due-date reminder to match
/// [loanReminderTime].
Future<void> syncLoanReminder(NotificationService service, Loan loan) async {
  final int id = loanReminderId(loan.id);
  final DateTime? reminderTime = loanReminderTime(loan);

  if (reminderTime == null) {
    await service.cancel(id);
    return;
  }

  const String title = 'Loan due soon';
  final String body = '${loan.personName} — ${AppFormatters.currency(loan.remainingAmount)} '
      'due ${AppFormatters.shortDate(loan.dueDate!)}.';

  await service.scheduleAt(
    id: id,
    title: title,
    body: body,
    dateTime: reminderTime,
    payload:
        buildNotificationPayload(type: notificationTypeLoan, id: loan.id, title: title, body: body)
            .toString(),
    actions: actionsFor(notificationTypeLoan),
  );
}

/// Cancels [loanId]'s reminder outright — used on delete, where there's
/// no updated entity left to re-derive the schedule from.
Future<void> cancelLoanReminder(NotificationService service, String loanId) {
  return service.cancel(loanReminderId(loanId));
}
