import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/finance/data/repositories/asset_mapper.dart';
import 'package:lifeos/features/finance/domain/entities/asset.dart';
import 'package:lifeos/features/finance/domain/entities/asset_type.dart';

Asset _buildAsset(String id, {bool isArchived = false, double currentValue = 500000}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Asset(
    id: id,
    name: 'Asset $id',
    type: AssetType.realEstate,
    currentValue: currentValue,
    colorValue: 0xFF7C4DFF,
    isArchived: isArchived,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('insertAsset persists a row retrievable by watchAsset', () async {
    await database.assetsDao.insertAsset(_buildAsset('a1').toCompanion());

    final row = await database.assetsDao.watchAsset('a1').first;
    expect(row?.currentValue, 500000);
  });

  test('watchActiveAssets excludes archived assets', () async {
    await database.assetsDao.insertAsset(_buildAsset('a1').toCompanion());
    await database.assetsDao.insertAsset(_buildAsset('a2', isArchived: true).toCompanion());

    final active = await database.assetsDao.watchActiveAssets().first;
    expect(active.map((r) => r.id), ['a1']);
  });

  test('updateAsset replaces the stored value', () async {
    await database.assetsDao.insertAsset(_buildAsset('a1').toCompanion());
    await database.assetsDao.updateAsset(_buildAsset('a1', currentValue: 600000).toCompanion());

    final row = await database.assetsDao.watchAsset('a1').first;
    expect(row?.currentValue, 600000);
  });

  test('deleteAsset removes the row', () async {
    await database.assetsDao.insertAsset(_buildAsset('a1').toCompanion());
    await database.assetsDao.deleteAsset('a1');

    final row = await database.assetsDao.watchAsset('a1').first;
    expect(row, isNull);
  });
}
