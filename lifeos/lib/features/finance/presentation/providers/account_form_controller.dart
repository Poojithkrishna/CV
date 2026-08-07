import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/account.dart';
import 'finance_providers.dart';

/// Drives the create/edit account form's submit action, exposing loading
/// and error state so the screen can show a spinner / snackbar without
/// managing that state itself.
class AccountFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<Account>> save(Account account, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<Account> result = isEditing
        ? await ref.read(updateAccountUseCaseProvider).call(account)
        : await ref.read(createAccountUseCaseProvider).call(account);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<AccountFormController, void>
    accountFormControllerProvider =
    AsyncNotifierProvider.autoDispose<AccountFormController, void>(
  AccountFormController.new,
);
