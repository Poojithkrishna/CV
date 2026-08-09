import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/notifications/notification_actions.dart';
import 'package:lifeos/core/notifications/notification_deep_link.dart';

void main() {
  group('actionsFor', () {
    test('a task gets Mark done and Snooze', () {
      final actions = actionsFor(notificationTypeTask);
      expect(actions.map((a) => a.id), [notificationActionMarkDone, notificationActionSnooze]);
      expect(actions.first.title, 'Mark done');
    });

    test('a recurring payment gets Mark paid and Snooze', () {
      final actions = actionsFor(notificationTypeRecurringPayment);
      expect(actions.map((a) => a.id), [notificationActionMarkDone, notificationActionSnooze]);
      expect(actions.first.title, 'Mark paid');
    });

    test('a loan only gets Snooze', () {
      final actions = actionsFor(notificationTypeLoan);
      expect(actions.map((a) => a.id), [notificationActionSnooze]);
    });

    test('an event only gets Snooze', () {
      final actions = actionsFor(notificationTypeEvent);
      expect(actions.map((a) => a.id), [notificationActionSnooze]);
    });

    test('an unrecognized type gets no actions', () {
      expect(actionsFor('nonexistent'), isEmpty);
    });

    test('every action shows the app UI when tapped', () {
      for (final String type in [
        notificationTypeTask,
        notificationTypeRecurringPayment,
        notificationTypeLoan,
        notificationTypeEvent,
      ]) {
        for (final AndroidNotificationAction action in actionsFor(type)) {
          expect(action.showsUserInterface, isTrue, reason: 'action ${action.id} for $type');
        }
      }
    });
  });
}
