import 'package:flutter/foundation.dart';

/// A persisted record that an [Achievement] (by its `key`) has been
/// earned. Once written, it's never removed — achievements don't
/// un-unlock if the underlying stat later regresses.
@immutable
class UnlockedAchievement {
  const UnlockedAchievement({required this.key, required this.unlockedAt});

  final String key;
  final DateTime unlockedAt;

  @override
  bool operator ==(Object other) => other is UnlockedAchievement && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
