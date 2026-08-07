import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/recurring_payment.dart';
import '../../domain/repositories/recurring_payment_repository.dart';
import '../daos/recurring_payments_dao.dart';
import 'recurring_payment_mapper.dart';

class RecurringPaymentRepositoryImpl implements RecurringPaymentRepository {
  RecurringPaymentRepositoryImpl(this._dao);

  final RecurringPaymentsDao _dao;

  @override
  Stream<List<RecurringPayment>> watchActivePayments() {
    return _dao
        .watchActivePayments()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<RecurringPayment?> watchPayment(String id) {
    return _dao.watchPayment(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<RecurringPayment>> createPayment(RecurringPayment payment) async {
    try {
      await _dao.insertPayment(payment.toCompanion());
      return Result.ok(payment);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save recurring payment: $e'));
    }
  }

  @override
  Future<Result<RecurringPayment>> updatePayment(RecurringPayment payment) async {
    try {
      final bool updated = await _dao.updatePayment(payment.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Recurring payment no longer exists.'));
      }
      return Result.ok(payment);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update recurring payment: $e'));
    }
  }

  @override
  Future<Result<void>> deletePayment(String id) async {
    try {
      await _dao.deletePayment(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete recurring payment: $e'));
    }
  }
}
