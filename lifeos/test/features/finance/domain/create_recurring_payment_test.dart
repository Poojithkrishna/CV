import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/recurrence_frequency.dart';
import 'package:lifeos/features/finance/domain/entities/recurring_payment.dart';
import 'package:lifeos/features/finance/domain/repositories/recurring_payment_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_recurring_payment.dart';

class _FakeRecurringPaymentRepository implements RecurringPaymentRepository {
  RecurringPayment? saved;

  @override
  Future<Result<RecurringPayment>> createPayment(RecurringPayment payment) async {
    saved = payment;
    return Result.ok(payment);
  }

  @override
  Future<Result<void>> deletePayment(String id) async => const Result.ok(null);

  @override
  Future<Result<RecurringPayment>> updatePayment(RecurringPayment payment) async =>
      Result.ok(payment);

  @override
  Stream<RecurringPayment?> watchPayment(String id) => const Stream.empty();

  @override
  Stream<List<RecurringPayment>> watchActivePayments() => const Stream.empty();
}

RecurringPayment _buildPayment({
  String name = 'Rent',
  double amount = 15000,
  int? reminderDaysBefore,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecurringPayment(
    id: 'bill-1',
    name: name,
    amount: amount,
    frequency: RecurrenceFrequency.monthly,
    nextDueDate: DateTime(2026, 1, 5),
    colorValue: 0xFF3B82F6,
    reminderDaysBefore: reminderDaysBefore,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateRecurringPayment', () {
    test('persists a valid payment', () async {
      final repo = _FakeRecurringPaymentRepository();
      final useCase = CreateRecurringPayment(repo);

      final result = await useCase(_buildPayment());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Rent');
    });

    test('rejects a blank name', () async {
      final repo = _FakeRecurringPaymentRepository();
      final useCase = CreateRecurringPayment(repo);

      final result = await useCase(_buildPayment(name: '   '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a zero amount', () async {
      final repo = _FakeRecurringPaymentRepository();
      final useCase = CreateRecurringPayment(repo);

      final result = await useCase(_buildPayment(amount: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects negative reminder days', () async {
      final repo = _FakeRecurringPaymentRepository();
      final useCase = CreateRecurringPayment(repo);

      final result = await useCase(_buildPayment(reminderDaysBefore: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
