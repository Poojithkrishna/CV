import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';
import '../repositories/recurring_payment_repository.dart';
import 'create_recurring_payment.dart';

class UpdateRecurringPayment {
  UpdateRecurringPayment(this._repository);

  final RecurringPaymentRepository _repository;

  Future<Result<RecurringPayment>> call(RecurringPayment payment) async {
    final Failure? error = CreateRecurringPayment.validate(payment);
    if (error != null) return Result.err(error);
    return _repository.updatePayment(payment.copyWith(updatedAt: DateTime.now()));
  }
}
