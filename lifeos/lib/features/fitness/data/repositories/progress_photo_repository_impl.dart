import '../../../../core/error/failures.dart';
import '../../../../core/utils/photo_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/photo_category.dart';
import '../../domain/entities/progress_photo.dart';
import '../../domain/repositories/progress_photo_repository.dart';
import '../daos/progress_photos_dao.dart';
import 'progress_photo_mapper.dart';

class ProgressPhotoRepositoryImpl implements ProgressPhotoRepository {
  ProgressPhotoRepositoryImpl(this._dao);

  final ProgressPhotosDao _dao;

  @override
  Stream<List<ProgressPhoto>> watchAllPhotos() {
    return _dao
        .watchAllPhotos()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<List<ProgressPhoto>> watchPhotosByCategory(PhotoCategory category) {
    return _dao
        .watchPhotosByCategory(category.name)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<ProgressPhoto>> addPhoto(ProgressPhoto photo) async {
    try {
      await _dao.insertPhoto(photo.toCompanion());
      return Result.ok(photo);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save photo: $e'));
    }
  }

  @override
  Future<Result<void>> deletePhoto(String id) async {
    try {
      final row = await _dao.getPhoto(id);
      await _dao.deletePhoto(id);
      if (row != null) {
        await deletePhotoFile(row.filePath);
      }
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete photo: $e'));
    }
  }
}
