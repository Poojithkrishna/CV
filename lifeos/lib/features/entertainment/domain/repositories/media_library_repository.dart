import '../../../../core/utils/result.dart';
import '../entities/media_item.dart';

abstract interface class MediaLibraryRepository {
  Stream<List<MediaItem>> watchAllItems();
  Stream<MediaItem?> watchItem(String id);
  Future<Result<MediaItem>> createItem(MediaItem item);
  Future<Result<MediaItem>> updateItem(MediaItem item);
  Future<Result<void>> deleteItem(String id);

  /// Adds [delta] (may be negative) to [id]'s `currentProgress`, floored
  /// at zero and capped at its `totalProgress` if one is set.
  Future<Result<void>> adjustProgress(String id, int delta);
}
