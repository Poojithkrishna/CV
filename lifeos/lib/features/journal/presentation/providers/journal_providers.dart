import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/journal_dao.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/usecases/create_journal_entry.dart';
import '../../domain/usecases/delete_journal_entry.dart';
import '../../domain/usecases/update_journal_entry.dart';

final Provider<JournalDao> journalDaoProvider = Provider<JournalDao>((ref) {
  return JournalDao(ref.watch(appDatabaseProvider));
});

final Provider<JournalRepository> journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(journalDaoProvider));
});

final Provider<CreateJournalEntry> createJournalEntryUseCaseProvider = Provider(
  (ref) => CreateJournalEntry(ref.watch(journalRepositoryProvider)),
);
final Provider<UpdateJournalEntry> updateJournalEntryUseCaseProvider = Provider(
  (ref) => UpdateJournalEntry(ref.watch(journalRepositoryProvider)),
);
final Provider<DeleteJournalEntry> deleteJournalEntryUseCaseProvider = Provider(
  (ref) => DeleteJournalEntry(ref.watch(journalRepositoryProvider)),
);

final StreamProvider<List<JournalEntry>> allJournalEntriesProvider =
    StreamProvider<List<JournalEntry>>((ref) {
  return ref.watch(journalRepositoryProvider).watchAllEntries();
});

final StreamProviderFamily<JournalEntry?, String> journalEntryByIdProvider =
    StreamProvider.family<JournalEntry?, String>((ref, id) {
  return ref.watch(journalRepositoryProvider).watchEntry(id);
});
