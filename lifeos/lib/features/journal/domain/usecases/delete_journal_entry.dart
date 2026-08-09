import '../../../../core/utils/result.dart';
import '../repositories/journal_repository.dart';

class DeleteJournalEntry {
  DeleteJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteEntry(id);
}
