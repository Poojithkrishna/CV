import '../../../../core/utils/result.dart';
import '../repositories/media_library_repository.dart';

class DeleteMediaItem {
  DeleteMediaItem(this._repository);

  final MediaLibraryRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteItem(id);
}
