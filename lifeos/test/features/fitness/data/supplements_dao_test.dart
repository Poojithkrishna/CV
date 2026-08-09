import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/supplement_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/supplement.dart';

Supplement _buildSupplement(String id, {bool isArchived = false}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Supplement(
    id: id,
    name: 'Supplement $id',
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

  final DateTime day = DateTime(2026, 1, 5);

  test('watchActiveSupplements excludes archived supplements', () async {
    await database.supplementsDao.insertSupplement(_buildSupplement('s1').toCompanion());
    await database.supplementsDao.insertSupplement(
      _buildSupplement('s2', isArchived: true).toCompanion(),
    );

    final active = await database.supplementsDao.watchActiveSupplements().first;
    expect(active.map((r) => r.id), ['s1']);
  });

  test('toggleTaken creates an entry defaulting to taken on the first toggle', () async {
    await database.supplementsDao.insertSupplement(_buildSupplement('s1').toCompanion());

    await database.supplementsDao.toggleTaken('s1', day);

    final entry = await database.supplementsDao.watchLogEntryForDate('s1', day).first;
    expect(entry?.taken, isTrue);
  });

  test('toggleTaken flips an existing entry back to not taken', () async {
    await database.supplementsDao.insertSupplement(_buildSupplement('s1').toCompanion());

    await database.supplementsDao.toggleTaken('s1', day);
    await database.supplementsDao.toggleTaken('s1', day);

    final entry = await database.supplementsDao.watchLogEntryForDate('s1', day).first;
    expect(entry?.taken, isFalse);
  });

  test('toggling on different days does not create duplicate rows for the same day', () async {
    await database.supplementsDao.insertSupplement(_buildSupplement('s1').toCompanion());

    await database.supplementsDao.toggleTaken('s1', day);
    await database.supplementsDao.toggleTaken('s1', day.add(const Duration(days: 1)));

    final today = await database.supplementsDao.watchLogEntryForDate('s1', day).first;
    final tomorrow =
        await database.supplementsDao.watchLogEntryForDate('s1', day.add(const Duration(days: 1))).first;
    expect(today?.taken, isTrue);
    expect(tomorrow?.taken, isTrue);
  });
}
