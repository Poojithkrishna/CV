import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/body_weight_entry.dart';
import '../../domain/repositories/body_weight_repository.dart';
import '../daos/body_weight_dao.dart';
import 'body_weight_mapper.dart';

class BodyWeightRepositoryImpl implements BodyWeightRepository {
  BodyWeightRepositoryImpl(this._dao);

  final BodyWeightDao _dao;

  @override
  Stream<List<BodyWeightEntry>> watchAllEntries() {
    return _dao
        .watchAllEntries()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<BodyWeightEntry?> watchEntryForDate(DateTime date) {
    return _dao.watchEntryForDate(date).map((row) => row?.toDomain());
  }

  @override
  Future<Result<BodyWeightEntry>> logWeight(BodyWeightEntry entry) async {
    try {
      await _dao.upsertForDate(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save weight entry: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    try {
      await _dao.deleteEntry(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete weight entry: $e'));
    }
  }
}
