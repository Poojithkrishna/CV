import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';
import '../repositories/recurring_payment_repository.dart';

class CreateRecurringPayment {
  CreateRecurringPayment(this._repository);

  final RecurringPaymentRepository _repository;

  Future<Result<RecurringPayment>> call(RecurringPayment payment) async {
    final Failure? error = validate(payment);
    if (error != null) return Result.err(error);
    return _repository.createPayment(payment);
  }

  static Failure? validate(RecurringPayment payment) {
    if (payment.name.trim().isEmpty) {
      return const ValidationFailure('Name is required.');
    }
    if (payment.amount <= 0) {
      return const ValidationFailure('Amount must be greater than zero.');
    }
    if (payment.reminderDaysBefore != null && payment.reminderDaysBefore! < 0) {
      return const ValidationFailure('Reminder days cannot be negative.');
    }
    return null;
  }
}
