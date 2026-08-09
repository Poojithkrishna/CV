import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/content_platform.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/entities/content_stage.dart';

extension ContentProjectRowMapper on ContentProjectRow {
  ContentProject toDomain() {
    return ContentProject(
      id: id,
      title: title,
      game: game,
      platform: ContentPlatform.values.byName(platform),
      stage: ContentStage.values.byName(stage),
      notes: notes,
      thumbnailPath: thumbnailPath,
      scheduledDate: scheduledDate,
      publishedDate: publishedDate,
      viewCount: viewCount,
      likeCount: likeCount,
      commentCount: commentCount,
      colorValue: colorValue,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ContentProjectEntityMapper on ContentProject {
  ContentProjectsCompanion toCompanion() {
    return ContentProjectsCompanion.insert(
      id: id,
      title: title,
      game: Value(game),
      platform: platform.name,
      stage: stage.name,
      notes: Value(notes),
      thumbnailPath: Value(thumbnailPath),
      scheduledDate: Value(scheduledDate),
      publishedDate: Value(publishedDate),
      viewCount: Value(viewCount),
      likeCount: Value(likeCount),
      commentCount: Value(commentCount),
      colorValue: colorValue,
      sortOrder: Value(sortOrder),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
