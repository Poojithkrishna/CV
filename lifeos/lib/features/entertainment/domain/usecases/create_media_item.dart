import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/media_item.dart';
import '../repositories/media_library_repository.dart';

class CreateMediaItem {
  CreateMediaItem(this._repository);

  final MediaLibraryRepository _repository;

  Future<Result<MediaItem>> call(MediaItem item) async {
    final Failure? error = validate(item);
    if (error != null) return Result.err(error);
    return _repository.createItem(item);
  }

  static Failure? validate(MediaItem item) {
    if (item.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    return null;
  }
}
