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
}
