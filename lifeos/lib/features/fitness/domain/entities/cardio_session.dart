import 'package:flutter/foundation.dart';

import 'cardio_type.dart';

@immutable
class CardioSession {
  const CardioSession({
    required this.id,
    required this.type,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.durationMinutes = 0,
    this.distanceKm,
    this.caloriesBurned,
    this.notes,
  });

  final String id;
  final CardioType type;
  final DateTime date;
  final double durationMinutes;
  final double? distanceKm;
  final double? caloriesBurned;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CardioSession copyWith({
    CardioType? type,
    DateTime? date,
    double? durationMinutes,
    double? distanceKm,
    bool clearDistanceKm = false,
    double? caloriesBurned,
    bool clearCaloriesBurned = false,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return CardioSession(
      id: id,
      type: type ?? this.type,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: clearDistanceKm ? null : (distanceKm ?? this.distanceKm),
      caloriesBurned: clearCaloriesBurned ? null : (caloriesBurned ?? this.caloriesBurned),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is CardioSession && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
