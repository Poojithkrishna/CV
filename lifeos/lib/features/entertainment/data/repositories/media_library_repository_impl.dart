import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_library_repository.dart';
import '../daos/media_library_dao.dart';
import 'media_item_mapper.dart';

class MediaLibraryRepositoryImpl implements MediaLibraryRepository {
  MediaLibraryRepositoryImpl(this._dao);

  final MediaLibraryDao _dao;

  @override
  Stream<List<MediaItem>> watchAllItems() {
    return _dao.watchAllItems().map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<MediaItem?> watchItem(String id) {
    return _dao.watchItem(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<MediaItem>> createItem(MediaItem item) async {
    try {
      await _dao.insertItem(item.toCompanion());
      return Result.ok(item);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save "${item.title}": $e'));
    }
  }

  @override
  Future<Result<MediaItem>> updateItem(MediaItem item) async {
    try {
      await _dao.updateItem(item.toCompanion());
      return Result.ok(item);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update "${item.title}": $e'));
    }
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      await _dao.deleteItem(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete item: $e'));
    }
  }

  @override
  Future<Result<void>> adjustProgress(String id, int delta) async {
    try {
      await _dao.adjustProgress(id, delta);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update progress: $e'));
    }
  }
}
