import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_status.dart';
import '../../domain/entities/media_type.dart';

extension MediaItemRowMapper on MediaItemRow {
  MediaItem toDomain() {
    return MediaItem(
      id: id,
      title: title,
      type: MediaType.values.byName(type),
      status: MediaStatus.values.byName(status),
      currentProgress: currentProgress,
      totalProgress: totalProgress,
      rating: rating,
      notes: notes,
      coverImagePath: coverImagePath,
      startedDate: startedDate,
      completedDate: completedDate,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MediaItemEntityMapper on MediaItem {
  MediaItemsCompanion toCompanion() {
    return MediaItemsCompanion.insert(
      id: id,
      title: title,
      type: type.name,
      status: status.name,
      currentProgress: Value(currentProgress),
      totalProgress: Value(totalProgress),
      rating: Value(rating),
      notes: Value(notes),
      coverImagePath: Value(coverImagePath),
      startedDate: Value(startedDate),
      completedDate: Value(completedDate),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
