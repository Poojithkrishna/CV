import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/recurring_payment.dart';
import 'recurring_payment_providers.dart';

class RecurringPaymentFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<RecurringPayment>> save(
    RecurringPayment payment, {
    required bool isEditing,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<RecurringPayment> result = isEditing
        ? await ref.read(updateRecurringPaymentUseCaseProvider).call(payment)
        : await ref.read(createRecurringPaymentUseCaseProvider).call(payment);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<RecurringPaymentFormController, void>
    recurringPaymentFormControllerProvider =
    AsyncNotifierProvider.autoDispose<RecurringPaymentFormController, void>(
  RecurringPaymentFormController.new,
);
