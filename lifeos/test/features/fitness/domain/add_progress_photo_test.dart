import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/photo_category.dart';
import 'package:lifeos/features/fitness/domain/entities/progress_photo.dart';
import 'package:lifeos/features/fitness/domain/repositories/progress_photo_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/add_progress_photo.dart';

class _FakeProgressPhotoRepository implements ProgressPhotoRepository {
  ProgressPhoto? saved;

  @override
  Future<Result<ProgressPhoto>> addPhoto(ProgressPhoto photo) async {
    saved = photo;
    return Result.ok(photo);
  }

  @override
  Future<Result<void>> deletePhoto(String id) async => const Result.ok(null);

  @override
  Stream<List<ProgressPhoto>> watchAllPhotos() => const Stream.empty();

  @override
  Stream<List<ProgressPhoto>> watchPhotosByCategory(PhotoCategory category) => const Stream.empty();
}

ProgressPhoto _buildPhoto({String filePath = '/tmp/photo.jpg'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return ProgressPhoto(
    id: 'p1',
    date: now,
    filePath: filePath,
    category: PhotoCategory.front,
    createdAt: now,
  );
}

void main() {
  group('AddProgressPhoto', () {
    test('persists a photo with a file path', () async {
      final repo = _FakeProgressPhotoRepository();
      final useCase = AddProgressPhoto(repo);

      final result = await useCase(_buildPhoto());

      expect(result.isOk, isTrue);
      expect(repo.saved?.filePath, '/tmp/photo.jpg');
    });

    test('rejects a blank file path', () async {
      final repo = _FakeProgressPhotoRepository();
      final useCase = AddProgressPhoto(repo);

      final result = await useCase(_buildPhoto(filePath: '  '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
