import '../../../../core/utils/result.dart';
import '../entities/photo_category.dart';
import '../entities/progress_photo.dart';

abstract interface class ProgressPhotoRepository {
  Stream<List<ProgressPhoto>> watchAllPhotos();
  Stream<List<ProgressPhoto>> watchPhotosByCategory(PhotoCategory category);

  Future<Result<ProgressPhoto>> addPhoto(ProgressPhoto photo);

  /// Deletes both the database row and the underlying image file.
  Future<Result<void>> deletePhoto(String id);
}
