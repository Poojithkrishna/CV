import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/recovery_entry.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../daos/recovery_dao.dart';
import 'recovery_mapper.dart';

class RecoveryRepositoryImpl implements RecoveryRepository {
  RecoveryRepositoryImpl(this._dao);

  final RecoveryDao _dao;

  @override
  Stream<List<RecoveryEntry>> watchAllEntries() {
    return _dao
        .watchAllEntries()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<RecoveryEntry?> watchEntryForDate(DateTime date) {
    return _dao.watchEntryForDate(date).map((row) => row?.toDomain());
  }

  @override
  Future<Result<RecoveryEntry>> logRecovery(RecoveryEntry entry) async {
    try {
      await _dao.upsertForDate(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save recovery entry: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    try {
      await _dao.deleteEntry(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete recovery entry: $e'));
    }
  }
}
