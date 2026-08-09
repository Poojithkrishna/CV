import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/finance/domain/entities/recurrence_frequency.dart';
import 'package:lifeos/features/finance/domain/entities/recurring_payment.dart';
import 'package:lifeos/features/finance/presentation/notifications/recurring_payment_reminders.dart';

RecurringPayment _buildPayment({
  required DateTime nextDueDate,
  int? reminderDaysBefore,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecurringPayment(
    id: 'payment-1',
    name: 'Internet bill',
    amount: 999,
    frequency: RecurrenceFrequency.monthly,
    nextDueDate: nextDueDate,
    reminderDaysBefore: reminderDaysBefore,
    colorValue: 0xFF22C55E,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('recurringPaymentReminderTime', () {
    test('is 9 AM reminderDaysBefore days before nextDueDate', () {
      final payment = _buildPayment(nextDueDate: DateTime(2026, 3, 10), reminderDaysBefore: 3);
      expect(recurringPaymentReminderTime(payment), DateTime(2026, 3, 7, 9));
    });

    test('is on the due date itself when reminderDaysBefore is zero', () {
      final payment = _buildPayment(nextDueDate: DateTime(2026, 3, 10), reminderDaysBefore: 0);
      expect(recurringPaymentReminderTime(payment), DateTime(2026, 3, 10, 9));
    });

    test('is null when reminderDaysBefore is not set', () {
      final payment = _buildPayment(nextDueDate: DateTime(2026, 3, 10), reminderDaysBefore: null);
      expect(recurringPaymentReminderTime(payment), isNull);
    });
  });
}
