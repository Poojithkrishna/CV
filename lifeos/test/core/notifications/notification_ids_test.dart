import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/notifications/notification_ids.dart';

void main() {
  group('notification id helpers', () {
    test('are deterministic for the same entity id', () {
      expect(loanReminderId('loan-1'), loanReminderId('loan-1'));
      expect(calendarTaskReminderId('task-1'), calendarTaskReminderId('task-1'));
    });

    test('differ across modules for the same underlying id string', () {
      // Same string, different module salts — must not collide, since a
      // loan and a calendar task could otherwise cancel each other's
      // reminder.
      const String sharedId = 'shared-uuid';
      final ids = {
        loanReminderId(sharedId),
        recurringPaymentReminderId(sharedId),
        calendarTaskReminderId(sharedId),
        calendarEventReminderId(sharedId),
      };
      expect(ids.length, 4);
    });

    test('are always non-negative (fit flutter_local_notifications\' int32 id)', () {
      for (final String id in ['a', 'b', 'loan-123', 'some-very-long-uuid-value-here']) {
        expect(loanReminderId(id), greaterThanOrEqualTo(0));
        expect(recurringPaymentReminderId(id), greaterThanOrEqualTo(0));
        expect(calendarTaskReminderId(id), greaterThanOrEqualTo(0));
        expect(calendarEventReminderId(id), greaterThanOrEqualTo(0));
      }
    });

    test('differ for different entity ids within the same module', () {
      expect(loanReminderId('loan-1'), isNot(loanReminderId('loan-2')));
    });
  });
}
