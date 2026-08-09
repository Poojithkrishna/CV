import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/body_weight_entry.dart';
import 'package:lifeos/features/fitness/domain/repositories/body_weight_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/log_body_weight.dart';

class _FakeBodyWeightRepository implements BodyWeightRepository {
  BodyWeightEntry? savedEntry;

  @override
  Future<Result<void>> deleteEntry(String id) async => const Result.ok(null);

  @override
  Future<Result<BodyWeightEntry>> logWeight(BodyWeightEntry entry) async {
    savedEntry = entry;
    return Result.ok(entry);
  }

  @override
  Stream<BodyWeightEntry?> watchEntryForDate(DateTime date) => const Stream.empty();

  @override
  Stream<List<BodyWeightEntry>> watchAllEntries() => const Stream.empty();
}

BodyWeightEntry _buildEntry({double weightKg = 75}) {
  final DateTime now = DateTime(2026, 1, 1);
  return BodyWeightEntry(id: 'e1', date: now, weightKg: weightKg, createdAt: now, updatedAt: now);
}

void main() {
  group('LogBodyWeight', () {
    test('persists a valid entry', () async {
      final repo = _FakeBodyWeightRepository();
      final useCase = LogBodyWeight(repo);

      final result = await useCase(_buildEntry());

      expect(result.isOk, isTrue);
      expect(repo.savedEntry?.weightKg, 75);
    });

    test('rejects a zero weight', () async {
      final repo = _FakeBodyWeightRepository();
      final useCase = LogBodyWeight(repo);

      final result = await useCase(_buildEntry(weightKg: 0));

      expect(result.isErr, isTrue);
      expect(repo.savedEntry, isNull);
    });

    test('rejects a negative weight', () async {
      final repo = _FakeBodyWeightRepository();
      final useCase = LogBodyWeight(repo);

      final result = await useCase(_buildEntry(weightKg: -5));

      expect(result.isErr, isTrue);
      expect(repo.savedEntry, isNull);
    });
  });
}
