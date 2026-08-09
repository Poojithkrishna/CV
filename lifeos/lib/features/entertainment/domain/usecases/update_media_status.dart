import '../../../../core/utils/result.dart';
import '../entities/media_item.dart';
import '../entities/media_status.dart';
import '../repositories/media_library_repository.dart';

/// Moves an item to a new status. Moving into [MediaStatus.inProgress]
/// for the first time stamps `startedDate`, and moving into
/// [MediaStatus.completed] for the first time stamps `completedDate` —
/// neither is ever cleared by moving back out (e.g. dropping something
/// you'd started, then picking it up again later), so "first started"
/// and "first completed" stay accurate.
class UpdateMediaStatus {
  UpdateMediaStatus(this._repository);

  final MediaLibraryRepository _repository;

  Future<Result<MediaItem>> call(MediaItem item, MediaStatus newStatus) {
    final MediaItem updated = item.copyWith(
      status: newStatus,
      startedDate: newStatus == MediaStatus.inProgress
          ? (item.startedDate ?? DateTime.now())
          : item.startedDate,
      completedDate: newStatus == MediaStatus.completed
          ? (item.completedDate ?? DateTime.now())
          : item.completedDate,
      updatedAt: DateTime.now(),
    );
    return _repository.updateItem(updated);
  }
}
