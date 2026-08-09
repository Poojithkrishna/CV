import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/photo_category.dart';
import '../../domain/entities/progress_photo.dart';

extension ProgressPhotoRowMapper on ProgressPhotoRow {
  ProgressPhoto toDomain() {
    return ProgressPhoto(
      id: id,
      date: date,
      filePath: filePath,
      category: PhotoCategory.values.byName(category),
      notes: notes,
      createdAt: createdAt,
    );
  }
}

extension ProgressPhotoEntityMapper on ProgressPhoto {
  ProgressPhotosCompanion toCompanion() {
    return ProgressPhotosCompanion.insert(
      id: id,
      date: date,
      filePath: filePath,
      category: category.name,
      notes: Value(notes),
      createdAt: createdAt,
    );
  }
}
