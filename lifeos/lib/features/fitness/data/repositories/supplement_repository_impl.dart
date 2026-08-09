import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/supplement.dart';
import '../../domain/entities/supplement_log_entry.dart';
import '../../domain/repositories/supplement_repository.dart';
import '../daos/supplements_dao.dart';
import 'supplement_log_entry_mapper.dart';
import 'supplement_mapper.dart';

class SupplementRepositoryImpl implements SupplementRepository {
  SupplementRepositoryImpl(this._dao);

  final SupplementsDao _dao;

  @override
  Stream<List<Supplement>> watchActiveSupplements() {
    return _dao
        .watchActiveSupplements()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Supplement?> watchSupplement(String id) {
    return _dao.watchSupplement(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Supplement>> createSupplement(Supplement supplement) async {
    try {
      await _dao.insertSupplement(supplement.toCompanion());
      return Result.ok(supplement);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save supplement: $e'));
    }
  }

  @override
  Future<Result<Supplement>> updateSupplement(Supplement supplement) async {
    try {
      final bool updated = await _dao.updateSupplement(supplement.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Supplement no longer exists.'));
      }
      return Result.ok(supplement);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update supplement: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSupplement(String id) async {
    try {
      await _dao.deleteSupplement(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete supplement: $e'));
    }
  }

  @override
  Stream<SupplementLogEntry?> watchLogEntryForDate(String supplementId, DateTime date) {
    return _dao.watchLogEntryForDate(supplementId, date).map((row) => row?.toDomain());
  }

  @override
  Future<Result<void>> toggleTaken(String supplementId, DateTime date) async {
    try {
      await _dao.toggleTaken(supplementId, date);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update supplement log: $e'));
    }
  }
}
