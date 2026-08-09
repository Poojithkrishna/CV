import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/journal/data/repositories/journal_entry_mapper.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry_type.dart';
import 'package:lifeos/features/journal/domain/entities/mood.dart';

JournalEntry _buildEntry({
  String id = 'e1',
  DateTime? date,
  DateTime? createdAt,
  Mood? mood,
}) {
  final DateTime now = createdAt ?? DateTime(2026, 1, 1);
  return JournalEntry(
    id: id,
    type: JournalEntryType.freeWriting,
    date: date ?? now,
    content: 'Some thoughts',
    mood: mood,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON;')),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('watchAllEntries orders by date descending, most recent first', () async {
    await database.journalDao.insertEntry(
      _buildEntry(id: 'e1', date: DateTime(2026, 1, 1)).toCompanion(),
    );
    await database.journalDao.insertEntry(
      _buildEntry(id: 'e2', date: DateTime(2026, 1, 10)).toCompanion(),
    );

    final entries = await database.journalDao.watchAllEntries().first;

    expect(entries.map((row) => row.id), ['e2', 'e1']);
  });

  test('updateEntry persists a mood change', () async {
    await database.journalDao.insertEntry(_buildEntry().toCompanion());
    final JournalEntry stored = (await database.journalDao.watchEntry('e1').first)!.toDomain();

    await database.journalDao.updateEntry(stored.copyWith(mood: Mood.great).toCompanion());

    final JournalEntry updated = (await database.journalDao.watchEntry('e1').first)!.toDomain();
    expect(updated.mood, Mood.great);
  });

  test('deleteEntry removes the row', () async {
    await database.journalDao.insertEntry(_buildEntry().toCompanion());
    await database.journalDao.deleteEntry('e1');
    expect(await database.journalDao.watchEntry('e1').first, isNull);
  });

  test('an entry with no mood round-trips as null', () async {
    await database.journalDao.insertEntry(_buildEntry(mood: null).toCompanion());
    final JournalEntry stored = (await database.journalDao.watchEntry('e1').first)!.toDomain();
    expect(stored.mood, isNull);
  });
}
