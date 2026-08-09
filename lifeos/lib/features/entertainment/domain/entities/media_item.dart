import 'package:flutter/foundation.dart';

import 'media_status.dart';
import 'media_type.dart';

/// A single game, movie, series, anime, book, manga or course being
/// tracked through the wishlist → in-progress → completed lifecycle.
@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.currentProgress = 0,
    this.totalProgress,
    this.rating,
    this.notes,
    this.coverImagePath,
    this.startedDate,
    this.completedDate,
  });

  final String id;
  final String title;
  final MediaType type;
  final MediaStatus status;

  /// Generic progress unit — episode, chapter, page, hour, whatever fits
  /// [type]. Meaningless (and left at 0) for things like movies.
  final int currentProgress;

  /// Total episodes/chapters/pages, if known. Null means "no fixed total"
  /// or "not tracked" rather than zero.
  final int? totalProgress;

  /// 0-10, set once the user rates it — meaningful at any status, not
  /// just once completed.
  final double? rating;

  final String? notes;
  final String? coverImagePath;

  /// Stamped the moment [status] first becomes [MediaStatus.inProgress].
  final DateTime? startedDate;

  /// Stamped the moment [status] first becomes [MediaStatus.completed].
  final DateTime? completedDate;

  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaItem copyWith({
    String? title,
    MediaType? type,
    MediaStatus? status,
    int? currentProgress,
    int? totalProgress,
    bool clearTotalProgress = false,
    double? rating,
    bool clearRating = false,
    String? notes,
    bool clearNotes = false,
    String? coverImagePath,
    bool clearCoverImagePath = false,
    DateTime? startedDate,
    DateTime? completedDate,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return MediaItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: clearTotalProgress ? null : (totalProgress ?? this.totalProgress),
      rating: clearRating ? null : (rating ?? this.rating),
      notes: clearNotes ? null : (notes ?? this.notes),
      coverImagePath: clearCoverImagePath ? null : (coverImagePath ?? this.coverImagePath),
      startedDate: startedDate ?? this.startedDate,
      completedDate: completedDate ?? this.completedDate,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is MediaItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
