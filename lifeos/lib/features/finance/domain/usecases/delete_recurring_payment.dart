import '../../../../core/utils/result.dart';
import '../repositories/recurring_payment_repository.dart';

class DeleteRecurringPayment {
  DeleteRecurringPayment(this._repository);

  final RecurringPaymentRepository _repository;

  Future<Result<void>> call(String id) => _repository.deletePayment(id);
}
