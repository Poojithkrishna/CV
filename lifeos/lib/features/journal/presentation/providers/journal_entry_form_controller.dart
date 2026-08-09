import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/journal_entry.dart';
import 'journal_providers.dart';

class JournalEntryFormController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Result<JournalEntry>> save(JournalEntry entry, {required bool isEditing}) async {
    state = const AsyncValue<void>.loading();
    final Result<JournalEntry> result = isEditing
        ? await ref.read(updateJournalEntryUseCaseProvider).call(entry)
        : await ref.read(createJournalEntryUseCaseProvider).call(entry);

    state = result.when(
      ok: (_) => const AsyncValue<void>.data(null),
      err: (failure) => AsyncValue<void>.error(failure, StackTrace.current),
    );
    return result;
  }
}

final AutoDisposeAsyncNotifierProvider<JournalEntryFormController, void>
    journalEntryFormControllerProvider =
    AsyncNotifierProvider.autoDispose<JournalEntryFormController, void>(
  JournalEntryFormController.new,
);
