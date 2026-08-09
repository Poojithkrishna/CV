import '../../../../core/utils/result.dart';
import '../entities/journal_entry.dart';

abstract interface class JournalRepository {
  Stream<List<JournalEntry>> watchAllEntries();
  Stream<JournalEntry?> watchEntry(String id);
  Future<Result<JournalEntry>> createEntry(JournalEntry entry);
  Future<Result<JournalEntry>> updateEntry(JournalEntry entry);
  Future<Result<void>> deleteEntry(String id);
}
