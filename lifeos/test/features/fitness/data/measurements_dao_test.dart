import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/measurement_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/measurement_entry.dart';
import 'package:lifeos/features/fitness/domain/entities/measurement_type.dart';

MeasurementEntry _buildEntry({
  String id = 'm1',
  MeasurementType type = MeasurementType.waist,
  required DateTime date,
  required double valueCm,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return MeasurementEntry(
    id: id,
    type: type,
    date: date,
    valueCm: valueCm,
    createdAt: now,
    updatedAt: now,
  );
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

  test('upsertForTypeAndDate inserts a new entry', () async {
    await database.measurementsDao.upsertForTypeAndDate(
      _buildEntry(date: day, valueCm: 82).toCompanion(),
    );

    final entries = await database.measurementsDao.watchEntriesForType('waist').first;
    expect(entries.single.valueCm, 82);
  });

  test('re-logging the same type and date overwrites rather than duplicating', () async {
    await database.measurementsDao.upsertForTypeAndDate(
      _buildEntry(id: 'm1', date: day, valueCm: 82).toCompanion(),
    );
    await database.measurementsDao.upsertForTypeAndDate(
      _buildEntry(id: 'm2', date: day, valueCm: 81.5).toCompanion(),
    );

    final entries = await database.measurementsDao.watchEntriesForType('waist').first;
    expect(entries.length, 1);
    expect(entries.single.valueCm, 81.5);
  });

  test('different types on the same date do not collide', () async {
    await database.measurementsDao.upsertForTypeAndDate(
      _buildEntry(id: 'm1', type: MeasurementType.waist, date: day, valueCm: 82).toCompanion(),
    );
    await database.measurementsDao.upsertForTypeAndDate(
      _buildEntry(id: 'm2', type: MeasurementType.chest, date: day, valueCm: 100).toCompanion(),
    );

    final all = await database.measurementsDao.watchAllEntries().first;
    expect(all.length, 2);
  });
}
