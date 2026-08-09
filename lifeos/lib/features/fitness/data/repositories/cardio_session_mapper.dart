import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/cardio_session.dart';
import '../../domain/entities/cardio_type.dart';

extension CardioSessionRowMapper on CardioSessionRow {
  CardioSession toDomain() {
    return CardioSession(
      id: id,
      type: CardioType.values.byName(type),
      date: date,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      caloriesBurned: caloriesBurned,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CardioSessionEntityMapper on CardioSession {
  CardioSessionsCompanion toCompanion() {
    return CardioSessionsCompanion.insert(
      id: id,
      type: type.name,
      date: date,
      durationMinutes: Value(durationMinutes),
      distanceKm: Value(distanceKm),
      caloriesBurned: Value(caloriesBurned),
      notes: Value(notes),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
