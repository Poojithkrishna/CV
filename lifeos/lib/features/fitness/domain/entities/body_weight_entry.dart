import 'package:flutter/foundation.dart';

@immutable
class BodyWeightEntry {
  const BodyWeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BodyWeightEntry copyWith({
    double? weightKg,
    String? notes,
    bool clearNotes = false,
    DateTime? updatedAt,
  }) {
    return BodyWeightEntry(
      id: id,
      date: date,
      weightKg: weightKg ?? this.weightKg,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is BodyWeightEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
