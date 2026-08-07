import '../../../../core/utils/result.dart';
import '../entities/recurring_payment.dart';

abstract interface class RecurringPaymentRepository {
  Stream<List<RecurringPayment>> watchActivePayments();
  Stream<RecurringPayment?> watchPayment(String id);

  Future<Result<RecurringPayment>> createPayment(RecurringPayment payment);
  Future<Result<RecurringPayment>> updatePayment(RecurringPayment payment);
  Future<Result<void>> deletePayment(String id);
}
