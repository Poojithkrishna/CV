import 'package:flutter/foundation.dart';

/// A raw highlight/clip captured for future content — optionally linked
/// to the `ContentProject` it eventually gets used in.
@immutable
class Clip {
  const Clip({
    required this.id,
    required this.title,
    required this.capturedAt,
    required this.createdAt,
    this.game = '',
    this.notes,
    this.thumbnailPath,
    this.linkedProjectId,
  });

  final String id;
  final String title;
  final String game;
  final String? notes;
  final String? thumbnailPath;
  final String? linkedProjectId;
  final DateTime capturedAt;
  final DateTime createdAt;

  Clip copyWith({
    String? title,
    String? game,
    String? notes,
    bool clearNotes = false,
    String? thumbnailPath,
    bool clearThumbnailPath = false,
    String? linkedProjectId,
    bool clearLinkedProjectId = false,
    DateTime? capturedAt,
  }) {
    return Clip(
      id: id,
      title: title ?? this.title,
      game: game ?? this.game,
      notes: clearNotes ? null : (notes ?? this.notes),
      thumbnailPath: clearThumbnailPath ? null : (thumbnailPath ?? this.thumbnailPath),
      linkedProjectId: clearLinkedProjectId ? null : (linkedProjectId ?? this.linkedProjectId),
      capturedAt: capturedAt ?? this.capturedAt,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Clip && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
