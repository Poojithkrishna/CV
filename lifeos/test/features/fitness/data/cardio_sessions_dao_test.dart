import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/cardio_session_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_session.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_type.dart';

CardioSession _buildSession(String id, {double durationMinutes = 30}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CardioSession(
    id: id,
    type: CardioType.running,
    date: now,
    durationMinutes: durationMinutes,
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

  test('insertSession persists a row retrievable by watchSession', () async {
    await database.cardioSessionsDao.insertSession(_buildSession('c1').toCompanion());

    final row = await database.cardioSessionsDao.watchSession('c1').first;
    expect(row?.durationMinutes, 30);
  });

  test('updateSession replaces the stored value', () async {
    await database.cardioSessionsDao.insertSession(_buildSession('c1').toCompanion());
    await database.cardioSessionsDao.updateSession(
      _buildSession('c1', durationMinutes: 45).toCompanion(),
    );

    final row = await database.cardioSessionsDao.watchSession('c1').first;
    expect(row?.durationMinutes, 45);
  });

  test('deleteSession removes the row', () async {
    await database.cardioSessionsDao.insertSession(_buildSession('c1').toCompanion());
    await database.cardioSessionsDao.deleteSession('c1');

    final row = await database.cardioSessionsDao.watchSession('c1').first;
    expect(row, isNull);
  });
}
