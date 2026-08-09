import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/media_item.dart';
import '../repositories/media_library_repository.dart';
import 'create_media_item.dart';

class UpdateMediaItem {
  UpdateMediaItem(this._repository);

  final MediaLibraryRepository _repository;

  Future<Result<MediaItem>> call(MediaItem item) async {
    final Failure? error = CreateMediaItem.validate(item);
    if (error != null) return Result.err(error);
    return _repository.updateItem(item);
  }
}
