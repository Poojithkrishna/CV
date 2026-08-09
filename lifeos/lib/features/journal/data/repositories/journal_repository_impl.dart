import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../daos/journal_dao.dart';
import 'journal_entry_mapper.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._dao);

  final JournalDao _dao;

  @override
  Stream<List<JournalEntry>> watchAllEntries() {
    return _dao.watchAllEntries().map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<JournalEntry?> watchEntry(String id) {
    return _dao.watchEntry(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<JournalEntry>> createEntry(JournalEntry entry) async {
    try {
      await _dao.insertEntry(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save entry: $e'));
    }
  }

  @override
  Future<Result<JournalEntry>> updateEntry(JournalEntry entry) async {
    try {
      await _dao.updateEntry(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update entry: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    try {
      await _dao.deleteEntry(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete entry: $e'));
    }
  }
}
