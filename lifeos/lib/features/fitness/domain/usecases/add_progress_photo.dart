import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/progress_photo.dart';
import '../repositories/progress_photo_repository.dart';

class AddProgressPhoto {
  AddProgressPhoto(this._repository);

  final ProgressPhotoRepository _repository;

  Future<Result<ProgressPhoto>> call(ProgressPhoto photo) async {
    if (photo.filePath.trim().isEmpty) {
      return const Result.err(ValidationFailure('Photo file is missing.'));
    }
    return _repository.addPhoto(photo);
  }
}
