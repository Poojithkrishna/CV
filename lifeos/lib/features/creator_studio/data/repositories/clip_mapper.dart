import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/clip.dart';

extension ClipRowMapper on ClipRow {
  Clip toDomain() {
    return Clip(
      id: id,
      title: title,
      game: game,
      notes: notes,
      thumbnailPath: thumbnailPath,
      linkedProjectId: linkedProjectId,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );
  }
}

extension ClipEntityMapper on Clip {
  ClipsCompanion toCompanion() {
    return ClipsCompanion.insert(
      id: id,
      title: title,
      game: Value(game),
      notes: Value(notes),
      thumbnailPath: Value(thumbnailPath),
      linkedProjectId: Value(linkedProjectId),
      capturedAt: capturedAt,
      createdAt: createdAt,
    );
  }
}
