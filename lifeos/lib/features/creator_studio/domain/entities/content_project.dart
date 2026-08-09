import 'package:flutter/foundation.dart';

import 'content_platform.dart';
import 'content_stage.dart';

/// A single piece of content moving through the Idea → Recording →
/// Editing → Thumbnail → Upload → Published pipeline.
@immutable
class ContentProject {
  const ContentProject({
    required this.id,
    required this.title,
    required this.stage,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.game = '',
    this.platform = ContentPlatform.youtube,
    this.notes,
    this.thumbnailPath,
    this.scheduledDate,
    this.publishedDate,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.sortOrder = 0,
  });

  final String id;
  final String title;

  /// Free-form — which game this content covers.
  final String game;

  final ContentPlatform platform;
  final ContentStage stage;
  final String? notes;
  final String? thumbnailPath;
  final DateTime? scheduledDate;

  /// Stamped the moment [stage] first becomes [ContentStage.published] —
  /// see `MoveProjectToStage`.
  final DateTime? publishedDate;

  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int colorValue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPublished => stage == ContentStage.published;

  ContentProject copyWith({
    String? title,
    String? game,
    ContentPlatform? platform,
    ContentStage? stage,
    String? notes,
    bool clearNotes = false,
    String? thumbnailPath,
    bool clearThumbnailPath = false,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    DateTime? publishedDate,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? colorValue,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return ContentProject(
      id: id,
      title: title ?? this.title,
      game: game ?? this.game,
      platform: platform ?? this.platform,
      stage: stage ?? this.stage,
      notes: clearNotes ? null : (notes ?? this.notes),
      thumbnailPath: clearThumbnailPath ? null : (thumbnailPath ?? this.thumbnailPath),
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      publishedDate: publishedDate ?? this.publishedDate,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is ContentProject && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
