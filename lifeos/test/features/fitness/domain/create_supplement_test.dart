import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/supplement.dart';
import 'package:lifeos/features/fitness/domain/entities/supplement_log_entry.dart';
import 'package:lifeos/features/fitness/domain/repositories/supplement_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/create_supplement.dart';
import 'package:lifeos/features/fitness/domain/usecases/toggle_supplement_taken.dart';

class _FakeSupplementRepository implements SupplementRepository {
  Supplement? saved;
  ({String supplementId, DateTime date})? toggled;

  @override
  Future<Result<Supplement>> createSupplement(Supplement supplement) async {
    saved = supplement;
    return Result.ok(supplement);
  }

  @override
  Future<Result<void>> deleteSupplement(String id) async => const Result.ok(null);

  @override
  Future<Result<Supplement>> updateSupplement(Supplement supplement) async => Result.ok(supplement);

  @override
  Stream<Supplement?> watchSupplement(String id) => const Stream.empty();

  @override
  Stream<List<Supplement>> watchActiveSupplements() => const Stream.empty();

  @override
  Stream<SupplementLogEntry?> watchLogEntryForDate(String supplementId, DateTime date) =>
      const Stream.empty();

  @override
  Future<Result<void>> toggleTaken(String supplementId, DateTime date) async {
    toggled = (supplementId: supplementId, date: date);
    return const Result.ok(null);
  }
}

Supplement _buildSupplement({String name = 'Vitamin D3'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Supplement(id: 's1', name: name, colorValue: 0xFF7C4DFF, createdAt: now, updatedAt: now);
}

void main() {
  group('CreateSupplement', () {
    test('persists a valid supplement', () async {
      final repo = _FakeSupplementRepository();
      final useCase = CreateSupplement(repo);

      final result = await useCase(_buildSupplement());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Vitamin D3');
    });

    test('rejects a blank name', () async {
      final repo = _FakeSupplementRepository();
      final useCase = CreateSupplement(repo);

      final result = await useCase(_buildSupplement(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });

  group('ToggleSupplementTaken', () {
    test('delegates to the repository with the given id and date', () async {
      final repo = _FakeSupplementRepository();
      final useCase = ToggleSupplementTaken(repo);
      final DateTime date = DateTime(2026, 1, 5);

      final result = await useCase('s1', date);

      expect(result.isOk, isTrue);
      expect(repo.toggled?.supplementId, 's1');
      expect(repo.toggled?.date, date);
    });
  });
}
