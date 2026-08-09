import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/notifications/notification_deep_link.dart';

void main() {
  group('routeForNotificationPayload', () {
    test('maps each known reminder type to its route', () {
      expect(routeForNotificationPayload('lifeos://notification/loan/l1'), '/finance/loans/l1');
      expect(
        routeForNotificationPayload('lifeos://notification/recurring-payment/p1'),
        '/finance/recurring-payments/p1',
      );
      expect(
        routeForNotificationPayload('lifeos://notification/task/t1'),
        '/calendar/tasks/t1/edit',
      );
      expect(
        routeForNotificationPayload('lifeos://notification/event/e1'),
        '/calendar/events/e1/edit',
      );
    });

    test('returns null for a null payload', () {
      expect(routeForNotificationPayload(null), isNull);
    });

    test('returns null for a payload that is not a valid uri', () {
      expect(routeForNotificationPayload('not a uri at all'), isNull);
    });

    test('returns null for an unrecognized reminder type', () {
      expect(routeForNotificationPayload('lifeos://notification/nonexistent/x1'), isNull);
    });

    test('returns null for a payload missing the id segment', () {
      expect(routeForNotificationPayload('lifeos://notification/loan'), isNull);
    });

    test('returns null for a mismatched scheme', () {
      expect(routeForNotificationPayload('https://notification/loan/l1'), isNull);
    });

    test('returns null for a mismatched host', () {
      expect(routeForNotificationPayload('lifeos://not-notification/loan/l1'), isNull);
    });
  });

  group('buildNotificationPayload / notificationContentFromPayload', () {
    test('round-trips type, id, title and body', () {
      final Uri payload = buildNotificationPayload(
        type: notificationTypeTask,
        id: 't1',
        title: 'Task due',
        body: 'Buy groceries',
      );

      final NotificationContent? content = notificationContentFromPayload(payload.toString());

      expect(content, isNotNull);
      expect(content!.type, notificationTypeTask);
      expect(content.id, 't1');
      expect(content.title, 'Task due');
      expect(content.body, 'Buy groceries');
    });

    test('round-trips a body containing reserved uri characters', () {
      final Uri payload = buildNotificationPayload(
        type: notificationTypeRecurringPayment,
        id: 'p1',
        title: 'Bill due soon',
        body: 'Electricity — ₹500 due 12/08 & tax? included',
      );

      final NotificationContent? content = notificationContentFromPayload(payload.toString());

      expect(content!.body, 'Electricity — ₹500 due 12/08 & tax? included');
    });

    test('returns empty strings for title/body when absent from the payload', () {
      final content = notificationContentFromPayload('lifeos://notification/loan/l1');
      expect(content!.title, '');
      expect(content.body, '');
    });

    test('returns null for a null payload', () {
      expect(notificationContentFromPayload(null), isNull);
    });
  });
}
