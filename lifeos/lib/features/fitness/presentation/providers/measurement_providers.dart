import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/measurements_dao.dart';
import '../../data/repositories/measurement_repository_impl.dart';
import '../../domain/entities/measurement_entry.dart';
import '../../domain/entities/measurement_type.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../../domain/usecases/delete_measurement.dart';
import '../../domain/usecases/log_measurement.dart';

final Provider<MeasurementsDao> measurementsDaoProvider = Provider<MeasurementsDao>((ref) {
  return MeasurementsDao(ref.watch(appDatabaseProvider));
});

final Provider<MeasurementRepository> measurementRepositoryProvider =
    Provider<MeasurementRepository>((ref) {
  return MeasurementRepositoryImpl(ref.watch(measurementsDaoProvider));
});

final Provider<LogMeasurement> logMeasurementUseCaseProvider = Provider(
  (ref) => LogMeasurement(ref.watch(measurementRepositoryProvider)),
);
final Provider<DeleteMeasurement> deleteMeasurementUseCaseProvider = Provider(
  (ref) => DeleteMeasurement(ref.watch(measurementRepositoryProvider)),
);

final StreamProviderFamily<List<MeasurementEntry>, MeasurementType> entriesForMeasurementTypeProvider =
    StreamProvider.family<List<MeasurementEntry>, MeasurementType>((ref, type) {
  return ref.watch(measurementRepositoryProvider).watchEntriesForType(type);
});

/// The most recent entry for every type that has at least one, keyed by
/// type — derived client-side from the full history stream (entries
/// arrive most-recent-first, so the first match per type is the latest).
final Provider<AsyncValue<Map<MeasurementType, MeasurementEntry>>> latestMeasurementsProvider =
    Provider<AsyncValue<Map<MeasurementType, MeasurementEntry>>>((ref) {
  final allEntriesAsync = ref.watch(_allMeasurementEntriesProvider);
  return allEntriesAsync.whenData((entries) {
    final Map<MeasurementType, MeasurementEntry> latest = {};
    for (final MeasurementEntry entry in entries) {
      latest.putIfAbsent(entry.type, () => entry);
    }
    return latest;
  });
});

final StreamProvider<List<MeasurementEntry>> _allMeasurementEntriesProvider =
    StreamProvider<List<MeasurementEntry>>((ref) {
  return ref.watch(measurementRepositoryProvider).watchAllEntries();
});
