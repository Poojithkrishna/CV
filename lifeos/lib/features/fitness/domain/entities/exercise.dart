import 'package:flutter/foundation.dart';

import 'equipment_type.dart';
import 'muscle_group.dart';

@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.createdAt,
    required this.updatedAt,
    this.instructions,
    this.isCustom = true,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final EquipmentType equipment;
  final String? instructions;

  /// False for the seeded starter library, true for anything the user adds.
  final bool isCustom;

  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    EquipmentType? equipment,
    String? instructions,
    bool clearInstructions = false,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      instructions: clearInstructions ? null : (instructions ?? this.instructions),
      isCustom: isCustom,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
