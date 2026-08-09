import 'package:flutter/foundation.dart';

@immutable
class ContentGoal {
  const ContentGoal({required this.weeklyUploadTarget, required this.updatedAt});

  final int weeklyUploadTarget;
  final DateTime updatedAt;
}
