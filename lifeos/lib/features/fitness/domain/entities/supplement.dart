import 'package:flutter/foundation.dart';

@immutable
class Supplement {
  const Supplement({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.dosageLabel = '',
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;

  /// Free-form label, e.g. "1000mg", "2 capsules".
  final String dosageLabel;

  final String? notes;
  final int colorValue;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Supplement copyWith({
    String? name,
    String? dosageLabel,
    String? notes,
    bool clearNotes = false,
    int? colorValue,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Supplement(
      id: id,
      name: name ?? this.name,
      dosageLabel: dosageLabel ?? this.dosageLabel,
      notes: clearNotes ? null : (notes ?? this.notes),
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Supplement && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
