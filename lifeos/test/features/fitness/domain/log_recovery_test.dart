import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/recovery_entry.dart';
import 'package:lifeos/features/fitness/domain/repositories/recovery_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/log_recovery.dart';

class _FakeRecoveryRepository implements RecoveryRepository {
  RecoveryEntry? saved;

  @override
  Future<Result<void>> deleteEntry(String id) async => const Result.ok(null);

  @override
  Future<Result<RecoveryEntry>> logRecovery(RecoveryEntry entry) async {
    saved = entry;
    return Result.ok(entry);
  }

  @override
  Stream<RecoveryEntry?> watchEntryForDate(DateTime date) => const Stream.empty();

  @override
  Stream<List<RecoveryEntry>> watchAllEntries() => const Stream.empty();
}

RecoveryEntry _buildEntry({double? sleepHours, int? sorenessLevel, int? stressLevel}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecoveryEntry(
    id: 'e1',
    date: now,
    sleepHours: sleepHours,
    sorenessLevel: sorenessLevel,
    stressLevel: stressLevel,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('LogRecovery', () {
    test('persists a valid entry', () async {
      final repo = _FakeRecoveryRepository();
      final useCase = LogRecovery(repo);

      final result = await useCase(_buildEntry(sleepHours: 7.5, sorenessLevel: 2, stressLevel: 3));

      expect(result.isOk, isTrue);
      expect(repo.saved?.sleepHours, 7.5);
    });

    test('accepts an entry with nothing logged yet (all fields null)', () async {
      final repo = _FakeRecoveryRepository();
      final useCase = LogRecovery(repo);

      final result = await useCase(_buildEntry());

      expect(result.isOk, isTrue);
    });

    test('rejects negative sleep hours', () async {
      final repo = _FakeRecoveryRepository();
      final useCase = LogRecovery(repo);

      final result = await useCase(_buildEntry(sleepHours: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a soreness level outside 1-5', () async {
      final repo = _FakeRecoveryRepository();
      final useCase = LogRecovery(repo);

      final result = await useCase(_buildEntry(sorenessLevel: 6));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a stress level outside 1-5', () async {
      final repo = _FakeRecoveryRepository();
      final useCase = LogRecovery(repo);

      final result = await useCase(_buildEntry(stressLevel: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
