import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/supplements_dao.dart';
import '../../data/repositories/supplement_repository_impl.dart';
import '../../domain/entities/supplement.dart';
import '../../domain/entities/supplement_log_entry.dart';
import '../../domain/repositories/supplement_repository.dart';
import '../../domain/usecases/create_supplement.dart';
import '../../domain/usecases/delete_supplement.dart';
import '../../domain/usecases/toggle_supplement_taken.dart';
import '../../domain/usecases/update_supplement.dart';

final Provider<SupplementsDao> supplementsDaoProvider = Provider<SupplementsDao>((ref) {
  return SupplementsDao(ref.watch(appDatabaseProvider));
});

final Provider<SupplementRepository> supplementRepositoryProvider =
    Provider<SupplementRepository>((ref) {
  return SupplementRepositoryImpl(ref.watch(supplementsDaoProvider));
});

final Provider<CreateSupplement> createSupplementUseCaseProvider = Provider(
  (ref) => CreateSupplement(ref.watch(supplementRepositoryProvider)),
);
final Provider<UpdateSupplement> updateSupplementUseCaseProvider = Provider(
  (ref) => UpdateSupplement(ref.watch(supplementRepositoryProvider)),
);
final Provider<DeleteSupplement> deleteSupplementUseCaseProvider = Provider(
  (ref) => DeleteSupplement(ref.watch(supplementRepositoryProvider)),
);
final Provider<ToggleSupplementTaken> toggleSupplementTakenUseCaseProvider = Provider(
  (ref) => ToggleSupplementTaken(ref.watch(supplementRepositoryProvider)),
);

final StreamProvider<List<Supplement>> activeSupplementsProvider =
    StreamProvider<List<Supplement>>((ref) {
  return ref.watch(supplementRepositoryProvider).watchActiveSupplements();
});

final StreamProviderFamily<Supplement?, String> supplementByIdProvider =
    StreamProvider.family<Supplement?, String>((ref, id) {
  return ref.watch(supplementRepositoryProvider).watchSupplement(id);
});

typedef SupplementDateKey = ({String supplementId, DateTime date});

final StreamProviderFamily<SupplementLogEntry?, SupplementDateKey> supplementLogForDateProvider =
    StreamProvider.family<SupplementLogEntry?, SupplementDateKey>((ref, key) {
  return ref.watch(supplementRepositoryProvider).watchLogEntryForDate(key.supplementId, key.date);
});
