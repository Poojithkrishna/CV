import '../../../../core/utils/result.dart';
import '../repositories/progress_photo_repository.dart';

class DeleteProgressPhoto {
  DeleteProgressPhoto(this._repository);

  final ProgressPhotoRepository _repository;

  Future<Result<void>> call(String id) => _repository.deletePhoto(id);
}
