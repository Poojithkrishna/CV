import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/recovery_dao.dart';
import '../../data/repositories/recovery_repository_impl.dart';
import '../../domain/entities/recovery_entry.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../domain/usecases/delete_recovery_entry.dart';
import '../../domain/usecases/log_recovery.dart';

final Provider<RecoveryDao> recoveryDaoProvider = Provider<RecoveryDao>((ref) {
  return RecoveryDao(ref.watch(appDatabaseProvider));
});

final Provider<RecoveryRepository> recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  return RecoveryRepositoryImpl(ref.watch(recoveryDaoProvider));
});

final Provider<LogRecovery> logRecoveryUseCaseProvider = Provider(
  (ref) => LogRecovery(ref.watch(recoveryRepositoryProvider)),
);
final Provider<DeleteRecoveryEntry> deleteRecoveryEntryUseCaseProvider = Provider(
  (ref) => DeleteRecoveryEntry(ref.watch(recoveryRepositoryProvider)),
);

final StreamProvider<List<RecoveryEntry>> recoveryEntriesProvider =
    StreamProvider<List<RecoveryEntry>>((ref) {
  return ref.watch(recoveryRepositoryProvider).watchAllEntries();
});

final StreamProvider<RecoveryEntry?> todayRecoveryEntryProvider =
    StreamProvider<RecoveryEntry?>((ref) {
  final DateTime now = DateTime.now();
  return ref.watch(recoveryRepositoryProvider).watchEntryForDate(DateTime(now.year, now.month, now.day));
});
