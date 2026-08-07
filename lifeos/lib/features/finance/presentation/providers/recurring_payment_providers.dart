import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/recurring_payments_dao.dart';
import '../../data/repositories/recurring_payment_repository_impl.dart';
import '../../domain/entities/recurring_payment.dart';
import '../../domain/repositories/recurring_payment_repository.dart';
import '../../domain/usecases/create_recurring_payment.dart';
import '../../domain/usecases/delete_recurring_payment.dart';
import '../../domain/usecases/mark_recurring_payment_paid.dart';
import '../../domain/usecases/update_recurring_payment.dart';
import 'transaction_providers.dart';

final Provider<RecurringPaymentsDao> recurringPaymentsDaoProvider =
    Provider<RecurringPaymentsDao>((ref) {
  return RecurringPaymentsDao(ref.watch(appDatabaseProvider));
});

final Provider<RecurringPaymentRepository> recurringPaymentRepositoryProvider =
    Provider<RecurringPaymentRepository>((ref) {
  return RecurringPaymentRepositoryImpl(ref.watch(recurringPaymentsDaoProvider));
});

final Provider<CreateRecurringPayment> createRecurringPaymentUseCaseProvider = Provider(
  (ref) => CreateRecurringPayment(ref.watch(recurringPaymentRepositoryProvider)),
);

final Provider<UpdateRecurringPayment> updateRecurringPaymentUseCaseProvider = Provider(
  (ref) => UpdateRecurringPayment(ref.watch(recurringPaymentRepositoryProvider)),
);

final Provider<DeleteRecurringPayment> deleteRecurringPaymentUseCaseProvider = Provider(
  (ref) => DeleteRecurringPayment(ref.watch(recurringPaymentRepositoryProvider)),
);

final Provider<MarkRecurringPaymentPaid> markRecurringPaymentPaidUseCaseProvider = Provider(
  (ref) => MarkRecurringPaymentPaid(
    ref.watch(recurringPaymentRepositoryProvider),
    ref.watch(createTransactionUseCaseProvider),
  ),
);

final StreamProvider<List<RecurringPayment>> activeRecurringPaymentsProvider =
    StreamProvider<List<RecurringPayment>>((ref) {
  return ref.watch(recurringPaymentRepositoryProvider).watchActivePayments();
});

final StreamProviderFamily<RecurringPayment?, String> recurringPaymentByIdProvider =
    StreamProvider.family<RecurringPayment?, String>((ref, id) {
  return ref.watch(recurringPaymentRepositoryProvider).watchPayment(id);
});
