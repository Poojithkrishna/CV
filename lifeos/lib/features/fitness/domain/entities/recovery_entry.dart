import 'package:flutter/foundation.dart';

@immutable
class RecoveryEntry {
  const RecoveryEntry({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.sleepHours,
    this.sorenessLevel,
    this.stressLevel,
    this.notes,
  });

  final String id;
  final DateTime date;

  final double? sleepHours;

  /// 1 (none) to 5 (very sore).
  final int? sorenessLevel;

  /// 1 (relaxed) to 5 (very stressed).
  final int? stressLevel;

  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) => other is RecoveryEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
