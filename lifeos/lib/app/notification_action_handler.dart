import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/notification_actions.dart';
import '../core/notifications/notification_deep_link.dart';
import '../core/providers/notification_provider.dart';
import '../features/calendar/presentation/notifications/calendar_reminders.dart';
import '../features/calendar/presentation/providers/calendar_providers.dart';
import '../features/finance/presentation/notifications/recurring_payment_reminders.dart';
import '../features/finance/presentation/providers/recurring_payment_providers.dart';

/// Reacts to a notification action button (Mark done, Mark paid,
/// Snooze). This needs cross-feature use cases (`ToggleTaskDone`,
/// `MarkRecurringPaymentPaid`) rather than just a route, so — unlike
/// `notification_deep_link_service.dart`'s plain-tap routing, which
/// stays feature-agnostic in `core/` — it lives here at the
/// composition root, the same reasoning `app_router.dart` already
/// follows for importing every feature's screens.
Future<void> handleNotificationActionResponse(
  ProviderContainer container,
  NotificationResponse? response,
) async {
  if (response == null) return;
  if (response.notificationResponseType != NotificationResponseType.selectedNotificationAction) {
    return;
  }

  final NotificationContent? content = notificationContentFromPayload(response.payload);
  if (content == null) return;

  if (response.actionId == notificationActionSnooze) {
    await _snooze(container, response.id, content);
  } else if (response.actionId == notificationActionMarkDone) {
    await _markDone(container, content);
  }
}

Future<void> _snooze(ProviderContainer container, int? notificationId, NotificationContent content) async {
  if (notificationId == null) return;

  await container.read(notificationServiceProvider).scheduleAt(
        id: notificationId,
        title: content.title,
        body: content.body,
        dateTime: DateTime.now().add(notificationSnoozeDuration),
        payload: buildNotificationPayload(
          type: content.type,
          id: content.id,
          title: content.title,
          body: content.body,
        ).toString(),
        actions: actionsFor(content.type),
      );
}

Future<void> _markDone(ProviderContainer container, NotificationContent content) async {
  if (content.type == notificationTypeTask) {
    await _markTaskDone(container, content.id);
  } else if (content.type == notificationTypeRecurringPayment) {
    await _markPaymentPaid(container, content.id);
  }
}

Future<void> _markTaskDone(ProviderContainer container, String taskId) async {
  await container.read(toggleTaskDoneUseCaseProvider).call(taskId);

  final task = await container.read(calendarRepositoryProvider).watchTask(taskId).first;
  if (task != null) {
    await syncTaskReminder(container.read(notificationServiceProvider), task);
  }
}

/// Marks the payment paid using its own scheduled amount — a
/// notification action has no dialog to collect a different actual
/// amount the way `RecurringPaymentDetailScreen`'s "Mark as paid"
/// button does.
Future<void> _markPaymentPaid(ProviderContainer container, String paymentId) async {
  final payment = await container.read(recurringPaymentRepositoryProvider).watchPayment(paymentId).first;
  if (payment == null) return;

  final result = await container.read(markRecurringPaymentPaidUseCaseProvider).call(payment);
  if (result.isOk) {
    await syncRecurringPaymentReminder(container.read(notificationServiceProvider), result.valueOrNull!);
  }
}
