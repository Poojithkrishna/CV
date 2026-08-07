import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/equipment_type.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_group.dart';

extension ExerciseRowMapper on ExerciseRow {
  Exercise toDomain() {
    return Exercise(
      id: id,
      name: name,
      muscleGroup: MuscleGroup.values.byName(muscleGroup),
      equipment: EquipmentType.values.byName(equipment),
      instructions: instructions,
      isCustom: isCustom,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ExerciseEntityMapper on Exercise {
  ExercisesCompanion toCompanion() {
    return ExercisesCompanion.insert(
      id: id,
      name: name,
      muscleGroup: muscleGroup.name,
      equipment: equipment.name,
      instructions: Value(instructions),
      isCustom: Value(isCustom),
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
