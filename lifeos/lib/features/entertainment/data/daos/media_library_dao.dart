import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/media_items_table.dart';

part 'media_library_dao.g.dart';

@DriftAccessor(tables: [MediaItems])
class MediaLibraryDao extends DatabaseAccessor<AppDatabase> with _$MediaLibraryDaoMixin {
  MediaLibraryDao(super.db);

  Stream<List<MediaItemRow>> watchAllItems() {
    return (select(mediaItems)..orderBy([(tbl) => OrderingTerm.asc(tbl.title)])).watch();
  }

  Stream<MediaItemRow?> watchItem(String id) {
    return (select(mediaItems)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertItem(MediaItemsCompanion entry) {
    return into(mediaItems).insert(entry);
  }

  Future<bool> updateItem(MediaItemsCompanion entry) {
    return update(mediaItems).replace(entry);
  }

  Future<int> deleteItem(String id) {
    return (delete(mediaItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Adds [delta] to the item's `currentProgress`, floored at zero and
  /// capped at `totalProgress` if one is set — mirrors `WaterDao.logWater`'s
  /// accumulate-delta upsert, minus the upsert (the row already exists).
  Future<void> adjustProgress(String id, int delta) {
    return transaction(() async {
      final MediaItemRow? row =
          await (select(mediaItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      int next = row.currentProgress + delta;
      if (next < 0) next = 0;
      final int? total = row.totalProgress;
      if (total != null && next > total) next = total;

      await (update(mediaItems)..where((tbl) => tbl.id.equals(id))).write(
        MediaItemsCompanion(currentProgress: Value(next), updatedAt: Value(DateTime.now())),
      );
    });
  }
}
