import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/entertainment/data/repositories/media_item_mapper.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_item.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_status.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_type.dart';

MediaItem _buildItem({
  String id = 'm1',
  String title = 'Item',
  int currentProgress = 0,
  int? totalProgress,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return MediaItem(
    id: id,
    title: title,
    type: MediaType.series,
    status: MediaStatus.inProgress,
    currentProgress: currentProgress,
    totalProgress: totalProgress,
    colorValue: 0xFF8B5CF6,
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

  test('watchAllItems orders alphabetically by title', () async {
    await database.mediaLibraryDao.insertItem(_buildItem(id: 'm2', title: 'Zeta').toCompanion());
    await database.mediaLibraryDao.insertItem(_buildItem(id: 'm1', title: 'Alpha').toCompanion());

    final items = await database.mediaLibraryDao.watchAllItems().first;

    expect(items.map((row) => row.id), ['m1', 'm2']);
  });

  test('updateItem persists a status change', () async {
    await database.mediaLibraryDao.insertItem(_buildItem().toCompanion());
    final MediaItem stored = (await database.mediaLibraryDao.watchItem('m1').first)!.toDomain();

    await database.mediaLibraryDao.updateItem(
      stored.copyWith(status: MediaStatus.completed).toCompanion(),
    );

    final MediaItem updated = (await database.mediaLibraryDao.watchItem('m1').first)!.toDomain();
    expect(updated.status, MediaStatus.completed);
  });

  test('deleteItem removes the row', () async {
    await database.mediaLibraryDao.insertItem(_buildItem().toCompanion());
    await database.mediaLibraryDao.deleteItem('m1');
    expect(await database.mediaLibraryDao.watchItem('m1').first, isNull);
  });

  group('adjustProgress', () {
    test('adds a positive delta to currentProgress', () async {
      await database.mediaLibraryDao.insertItem(
        _buildItem(currentProgress: 2, totalProgress: 12).toCompanion(),
      );

      await database.mediaLibraryDao.adjustProgress('m1', 1);

      final MediaItem updated = (await database.mediaLibraryDao.watchItem('m1').first)!.toDomain();
      expect(updated.currentProgress, 3);
    });

    test('floors a negative delta at zero', () async {
      await database.mediaLibraryDao.insertItem(
        _buildItem(currentProgress: 1, totalProgress: 12).toCompanion(),
      );

      await database.mediaLibraryDao.adjustProgress('m1', -5);

      final MediaItem updated = (await database.mediaLibraryDao.watchItem('m1').first)!.toDomain();
      expect(updated.currentProgress, 0);
    });

    test('caps a positive delta at totalProgress', () async {
      await database.mediaLibraryDao.insertItem(
        _buildItem(currentProgress: 11, totalProgress: 12).toCompanion(),
      );

      await database.mediaLibraryDao.adjustProgress('m1', 5);

      final MediaItem updated = (await database.mediaLibraryDao.watchItem('m1').first)!.toDomain();
      expect(updated.currentProgress, 12);
    });

    test('is a no-op for an id that does not exist', () async {
      await database.mediaLibraryDao.adjustProgress('missing', 1);
      expect(await database.mediaLibraryDao.watchItem('missing').first, isNull);
    });
  });
}
