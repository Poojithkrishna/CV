import 'package:flutter/foundation.dart';

import 'photo_category.dart';

@immutable
class ProgressPhoto {
  const ProgressPhoto({
    required this.id,
    required this.date,
    required this.filePath,
    required this.category,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final DateTime date;
  final String filePath;
  final PhotoCategory category;
  final String? notes;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) => other is ProgressPhoto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
