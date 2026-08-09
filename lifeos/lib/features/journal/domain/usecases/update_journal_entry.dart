import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';
import 'create_journal_entry.dart';

class UpdateJournalEntry {
  UpdateJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<Result<JournalEntry>> call(JournalEntry entry) async {
    final Failure? error = CreateJournalEntry.validate(entry);
    if (error != null) return Result.err(error);
    return _repository.updateEntry(entry);
  }
}
