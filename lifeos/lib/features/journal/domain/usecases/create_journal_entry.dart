import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class CreateJournalEntry {
  CreateJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<Result<JournalEntry>> call(JournalEntry entry) async {
    final Failure? error = validate(entry);
    if (error != null) return Result.err(error);
    return _repository.createEntry(entry);
  }

  static Failure? validate(JournalEntry entry) {
    if (entry.content.trim().isEmpty) {
      return const ValidationFailure('Write something before saving.');
    }
    return null;
  }
}
