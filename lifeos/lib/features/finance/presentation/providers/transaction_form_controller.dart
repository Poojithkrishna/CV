import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/transaction_entry.dart';
import 'transaction_providers.dart';

class TransactionFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<TransactionEntry>> save(
    TransactionEntry entry, {
    required bool isEditing,
  }) async {
    state = const AsyncValue<void>.loading();
    final Result<TransactionEntry> result = isEditing
        ? await ref.read(updateTransactionUseCaseProvider).call(entry)
        : await ref.read(createTransactionUseCaseProvider).call(entry);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<TransactionFormController, void>
    transactionFormControllerProvider =
    AsyncNotifierProvider.autoDispose<TransactionFormController, void>(
  TransactionFormController.new,
);
