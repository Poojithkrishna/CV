import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/finance/domain/entities/loan.dart';
import 'package:lifeos/features/finance/domain/entities/loan_direction.dart';
import 'package:lifeos/features/finance/presentation/notifications/loan_reminders.dart';

Loan _buildLoan({
  DateTime? dueDate,
  bool reminderEnabled = true,
  double remainingAmount = 5000,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Loan(
    id: 'loan-1',
    direction: LoanDirection.given,
    personName: 'Alex',
    principalAmount: 5000,
    remainingAmount: remainingAmount,
    dueDate: dueDate,
    reminderEnabled: reminderEnabled,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('loanReminderTime', () {
    test('is 9 AM one day before the due date when enabled', () {
      final loan = _buildLoan(dueDate: DateTime(2026, 3, 10));
      expect(loanReminderTime(loan), DateTime(2026, 3, 9, 9));
    });

    test('is null when the toggle is off', () {
      final loan = _buildLoan(dueDate: DateTime(2026, 3, 10), reminderEnabled: false);
      expect(loanReminderTime(loan), isNull);
    });

    test('is null with no due date', () {
      final loan = _buildLoan(reminderEnabled: true);
      expect(loanReminderTime(loan), isNull);
    });

    test('is null once the loan is settled, even if still enabled', () {
      final loan = _buildLoan(dueDate: DateTime(2026, 3, 10), remainingAmount: 0);
      expect(loanReminderTime(loan), isNull);
    });
  });
}
