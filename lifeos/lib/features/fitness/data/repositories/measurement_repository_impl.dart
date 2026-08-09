import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../daos/measurements_dao.dart';
import 'measurement_mapper.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  MeasurementRepositoryImpl(this._dao);

  final MeasurementsDao _dao;

  @override
  Stream<List<MeasurementEntry>> watchEntriesForType(MeasurementType type) {
    return _dao
        .watchEntriesForType(type.name)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<List<MeasurementEntry>> watchAllEntries() {
    return _dao
        .watchAllEntries()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<MeasurementEntry>> logMeasurement(MeasurementEntry entry) async {
    try {
      await _dao.upsertForTypeAndDate(entry.toCompanion());
      return Result.ok(entry);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save measurement: $e'));
    }
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    try {
      await _dao.deleteEntry(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete measurement: $e'));
    }
  }
}
