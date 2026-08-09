import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_deep_link.dart';

/// Action ids shared between the buttons a reminder attaches (see
/// [actionsFor]) and the handling logic that reacts to them (see
/// `notification_action_handler.dart`). Plain string constants rather
/// than an enum since `AndroidNotificationAction` expects a String id.
const String notificationActionMarkDone = 'mark_done';
const String notificationActionSnooze = 'snooze';

/// A short, fixed snooze — long enough to genuinely defer a reminder,
/// short enough that it still re-fires the same day for anything due
/// soon. Not user-configurable; this is a quick-action shortcut, not a
/// full reschedule UI.
const Duration notificationSnoozeDuration = Duration(hours: 3);

/// `showsUserInterface: true` on every action here is a deliberate
/// trade-off: it means tapping "Mark done" or "Snooze" always
/// foregrounds (or cold-launches) the app to handle the tap through the
/// same `onDidReceiveNotificationResponse`/`getNotificationAppLaunchDetails`
/// pipeline already wired for plain taps, rather than requiring a
/// separate background-isolate entry point that can run Dart code (and
/// re-open the database) while the app process is fully killed. It's a
/// little less slick than a true no-open quick action, but avoids a
/// second, much more complex code path for something that still
/// completes in under a second.
AndroidNotificationAction markDoneAction(String label) {
  return AndroidNotificationAction(notificationActionMarkDone, label, showsUserInterface: true);
}

AndroidNotificationAction snoozeAction() {
  return const AndroidNotificationAction(
    notificationActionSnooze,
    'Snooze',
    showsUserInterface: true,
  );
}

/// Which action buttons a reminder of [type] gets. A Task and a bill
/// each have a real "this is handled" action (Mark done / Mark paid);
/// a Loan and a calendar Event don't — settling a loan needs a payment
/// amount a notification button can't collect, and an event has no
/// "done" state at all — so those two only get Snooze. Also used to
/// re-attach the same buttons when a Snooze reschedules a notification,
/// so a snoozed reminder doesn't quietly lose its actions.
List<AndroidNotificationAction> actionsFor(String type) {
  switch (type) {
    case notificationTypeTask:
      return [markDoneAction('Mark done'), snoozeAction()];
    case notificationTypeRecurringPayment:
      return [markDoneAction('Mark paid'), snoozeAction()];
    case notificationTypeLoan:
    case notificationTypeEvent:
      return [snoozeAction()];
    default:
      return [];
  }
}
