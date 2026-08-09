import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/body_weight_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/body_weight_entry.dart';

BodyWeightEntry _buildEntry({String id = 'e1', required DateTime date, required double weightKg}) {
  final DateTime now = DateTime(2026, 1, 1);
  return BodyWeightEntry(id: id, date: date, weightKg: weightKg, createdAt: now, updatedAt: now);
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  final DateTime day = DateTime(2026, 1, 5);

  test('upsertForDate inserts a new entry for a fresh date', () async {
    await database.bodyWeightDao.upsertForDate(
      _buildEntry(date: day, weightKg: 80).toCompanion(),
    );

    final entry = await database.bodyWeightDao.watchEntryForDate(day).first;
    expect(entry?.weightKg, 80);
  });

  test('upsertForDate overwrites the existing entry for the same date', () async {
    await database.bodyWeightDao.upsertForDate(
      _buildEntry(id: 'e1', date: day, weightKg: 80).toCompanion(),
    );
    await database.bodyWeightDao.upsertForDate(
      _buildEntry(id: 'e2', date: day, weightKg: 79.5).toCompanion(),
    );

    final entries = await database.bodyWeightDao.watchAllEntries().first;
    expect(entries.length, 1);
    expect(entries.single.weightKg, 79.5);
  });

  test('entries for different dates do not collide', () async {
    await database.bodyWeightDao.upsertForDate(
      _buildEntry(id: 'e1', date: day, weightKg: 80).toCompanion(),
    );
    await database.bodyWeightDao.upsertForDate(
      _buildEntry(id: 'e2', date: day.add(const Duration(days: 1)), weightKg: 79.8).toCompanion(),
    );

    final entries = await database.bodyWeightDao.watchAllEntries().first;
    expect(entries.length, 2);
  });
}
