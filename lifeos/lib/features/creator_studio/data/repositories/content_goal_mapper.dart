import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/content_goal.dart';
import '../tables/content_goal_table.dart';

extension ContentGoalRowMapper on ContentGoalRow {
  ContentGoal toDomain() {
    return ContentGoal(weeklyUploadTarget: weeklyUploadTarget, updatedAt: updatedAt);
  }
}

extension ContentGoalEntityMapper on ContentGoal {
  ContentGoalsCompanion toCompanion() {
    return ContentGoalsCompanion.insert(
      id: kDefaultContentGoalId,
      weeklyUploadTarget: Value(weeklyUploadTarget),
      updatedAt: updatedAt,
    );
  }
}
