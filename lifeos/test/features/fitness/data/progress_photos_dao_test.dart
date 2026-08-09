import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/fitness/data/repositories/progress_photo_mapper.dart';
import 'package:lifeos/features/fitness/domain/entities/photo_category.dart';
import 'package:lifeos/features/fitness/domain/entities/progress_photo.dart';

ProgressPhoto _buildPhoto(String id, {PhotoCategory category = PhotoCategory.front}) {
  final DateTime now = DateTime(2026, 1, 1);
  return ProgressPhoto(
    id: id,
    date: now,
    filePath: '/tmp/$id.jpg',
    category: category,
    createdAt: now,
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

  test('insertPhoto persists a row retrievable by getPhoto', () async {
    await database.progressPhotosDao.insertPhoto(_buildPhoto('p1').toCompanion());

    final row = await database.progressPhotosDao.getPhoto('p1');
    expect(row?.filePath, '/tmp/p1.jpg');
  });

  test('watchPhotosByCategory filters to the requested category', () async {
    await database.progressPhotosDao.insertPhoto(
      _buildPhoto('p1', category: PhotoCategory.front).toCompanion(),
    );
    await database.progressPhotosDao.insertPhoto(
      _buildPhoto('p2', category: PhotoCategory.side).toCompanion(),
    );

    final frontPhotos = await database.progressPhotosDao.watchPhotosByCategory('front').first;
    expect(frontPhotos.map((r) => r.id), ['p1']);
  });

  test('deletePhoto removes the row', () async {
    await database.progressPhotosDao.insertPhoto(_buildPhoto('p1').toCompanion());
    await database.progressPhotosDao.deletePhoto('p1');

    final row = await database.progressPhotosDao.getPhoto('p1');
    expect(row, isNull);
  });
}
