import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/asset.dart';
import 'package:lifeos/features/finance/domain/entities/asset_type.dart';
import 'package:lifeos/features/finance/domain/repositories/asset_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_asset.dart';

class _FakeAssetRepository implements AssetRepository {
  Asset? saved;

  @override
  Future<Result<Asset>> createAsset(Asset asset) async {
    saved = asset;
    return Result.ok(asset);
  }

  @override
  Future<Result<void>> deleteAsset(String id) async => const Result.ok(null);

  @override
  Future<Result<Asset>> updateAsset(Asset asset) async => Result.ok(asset);

  @override
  Stream<Asset?> watchAsset(String id) => const Stream.empty();

  @override
  Stream<List<Asset>> watchActiveAssets() => const Stream.empty();
}

Asset _buildAsset({double currentValue = 500000, double? purchasePrice}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Asset(
    id: 'a1',
    name: 'Downtown Apartment',
    type: AssetType.realEstate,
    currentValue: currentValue,
    purchasePrice: purchasePrice,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateAsset', () {
    test('persists a valid asset', () async {
      final repo = _FakeAssetRepository();
      final useCase = CreateAsset(repo);

      final result = await useCase(_buildAsset());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Downtown Apartment');
    });

    test('rejects a blank name', () async {
      final repo = _FakeAssetRepository();
      final useCase = CreateAsset(repo);

      final result = await useCase(_buildAsset().copyWith(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative current value', () async {
      final repo = _FakeAssetRepository();
      final useCase = CreateAsset(repo);

      final result = await useCase(_buildAsset(currentValue: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative purchase price', () async {
      final repo = _FakeAssetRepository();
      final useCase = CreateAsset(repo);

      final result = await useCase(_buildAsset(purchasePrice: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('accepts a null purchase price', () async {
      final repo = _FakeAssetRepository();
      final useCase = CreateAsset(repo);

      final result = await useCase(_buildAsset());

      expect(result.isOk, isTrue);
      expect(repo.saved?.purchasePrice, isNull);
    });
  });
}
