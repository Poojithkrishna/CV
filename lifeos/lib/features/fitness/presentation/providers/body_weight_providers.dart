import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/body_weight_dao.dart';
import '../../data/repositories/body_weight_repository_impl.dart';
import '../../domain/entities/body_weight_entry.dart';
import '../../domain/repositories/body_weight_repository.dart';
import '../../domain/usecases/delete_body_weight_entry.dart';
import '../../domain/usecases/log_body_weight.dart';

final Provider<BodyWeightDao> bodyWeightDaoProvider = Provider<BodyWeightDao>((ref) {
  return BodyWeightDao(ref.watch(appDatabaseProvider));
});

final Provider<BodyWeightRepository> bodyWeightRepositoryProvider =
    Provider<BodyWeightRepository>((ref) {
  return BodyWeightRepositoryImpl(ref.watch(bodyWeightDaoProvider));
});

final Provider<LogBodyWeight> logBodyWeightUseCaseProvider = Provider(
  (ref) => LogBodyWeight(ref.watch(bodyWeightRepositoryProvider)),
);
final Provider<DeleteBodyWeightEntry> deleteBodyWeightEntryUseCaseProvider = Provider(
  (ref) => DeleteBodyWeightEntry(ref.watch(bodyWeightRepositoryProvider)),
);

final StreamProvider<List<BodyWeightEntry>> bodyWeightEntriesProvider =
    StreamProvider<List<BodyWeightEntry>>((ref) {
  return ref.watch(bodyWeightRepositoryProvider).watchAllEntries();
});

final StreamProvider<BodyWeightEntry?> latestBodyWeightEntryProvider =
    StreamProvider<BodyWeightEntry?>((ref) {
  return ref.watch(bodyWeightEntriesProvider.stream).map(
        (entries) => entries.isEmpty ? null : entries.last,
      );
});
