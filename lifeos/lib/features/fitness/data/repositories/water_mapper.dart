import '../../../../core/database/app_database.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/entities/water_goal.dart';

extension WaterEntryRowMapper on WaterEntryRow {
  WaterEntry toDomain() {
    return WaterEntry(id: id, date: date, amountMl: amountMl, updatedAt: updatedAt);
  }
}

extension WaterGoalRowMapper on WaterGoalRow {
  WaterGoal toDomain() {
    return WaterGoal(dailyGoalMl: dailyGoalMl, updatedAt: updatedAt);
  }
}
