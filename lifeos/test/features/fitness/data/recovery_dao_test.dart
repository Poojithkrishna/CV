import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/recovery_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/recovery_entry.dart';

RecoveryEntry _buildEntry({String id = 'r1', required DateTime date, double? sleepHours}) {
  final DateTime now = DateTime(2026, 1, 1);
  return RecoveryEntry(
    id: id,
    date: date,
    sleepHours: sleepHours,
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

  test('upsertForDate inserts a new entry for a fresh date', () async {
    await database.recoveryDao.upsertForDate(_buildEntry(date: day, sleepHours: 7).toCompanion());

    final entry = await database.recoveryDao.watchEntryForDate(day).first;
    expect(entry?.sleepHours, 7);
  });

  test('upsertForDate overwrites the existing entry for the same date', () async {
    await database.recoveryDao.upsertForDate(
      _buildEntry(id: 'r1', date: day, sleepHours: 7).toCompanion(),
    );
    await database.recoveryDao.upsertForDate(
      _buildEntry(id: 'r2', date: day, sleepHours: 8.5).toCompanion(),
    );

    final entries = await database.recoveryDao.watchAllEntries().first;
    expect(entries.length, 1);
    expect(entries.single.sleepHours, 8.5);
  });

  test('entries for different dates do not collide', () async {
    await database.recoveryDao.upsertForDate(
      _buildEntry(id: 'r1', date: day, sleepHours: 7).toCompanion(),
    );
    await database.recoveryDao.upsertForDate(
      _buildEntry(id: 'r2', date: day.add(const Duration(days: 1)), sleepHours: 6).toCompanion(),
    );

    final entries = await database.recoveryDao.watchAllEntries().first;
    expect(entries.length, 2);
  });

  test('deleteEntry removes the row', () async {
    await database.recoveryDao.upsertForDate(_buildEntry(id: 'r1', date: day).toCompanion());
    await database.recoveryDao.deleteEntry('r1');

    final entry = await database.recoveryDao.watchEntryForDate(day).first;
    expect(entry, isNull);
  });
}
