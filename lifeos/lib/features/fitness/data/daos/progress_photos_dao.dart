import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/progress_photos_table.dart';

part 'progress_photos_dao.g.dart';

@DriftAccessor(tables: [ProgressPhotos])
class ProgressPhotosDao extends DatabaseAccessor<AppDatabase> with _$ProgressPhotosDaoMixin {
  ProgressPhotosDao(super.db);

  Stream<List<ProgressPhotoRow>> watchAllPhotos() {
    return (select(progressPhotos)..orderBy([(tbl) => OrderingTerm.desc(tbl.date)])).watch();
  }

  Stream<List<ProgressPhotoRow>> watchPhotosByCategory(String category) {
    return (select(progressPhotos)
          ..where((tbl) => tbl.category.equals(category))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .watch();
  }

  Future<ProgressPhotoRow?> getPhoto(String id) {
    return (select(progressPhotos)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertPhoto(ProgressPhotosCompanion entry) {
    return into(progressPhotos).insert(entry);
  }

  Future<int> deletePhoto(String id) {
    return (delete(progressPhotos)..where((tbl) => tbl.id.equals(id))).go();
  }
}
