import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/goal.dart';

extension GoalRowMapper on GoalRow {
  Goal toDomain() {
    return Goal(
      id: id,
      title: title,
      description: description,
      targetDate: targetDate,
      progressValue: progressValue,
      targetValue: targetValue,
      colorValue: colorValue,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension GoalEntityMapper on Goal {
  GoalsCompanion toCompanion() {
    return GoalsCompanion.insert(
      id: id,
      title: title,
      description: Value(description),
      targetDate: Value(targetDate),
      progressValue: Value(progressValue),
      targetValue: Value(targetValue),
      colorValue: colorValue,
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
