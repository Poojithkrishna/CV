import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/milestone.dart';

extension MilestoneRowMapper on MilestoneRow {
  Milestone toDomain() {
    return Milestone(
      id: id,
      goalId: goalId,
      title: title,
      targetDate: targetDate,
      isCompleted: isCompleted,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MilestoneEntityMapper on Milestone {
  MilestonesCompanion toCompanion() {
    return MilestonesCompanion.insert(
      id: id,
      goalId: goalId,
      title: title,
      targetDate: Value(targetDate),
      isCompleted: Value(isCompleted),
      sortOrder: Value(sortOrder),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
