import '../../../../core/utils/result.dart';
import '../entities/water_entry.dart';
import '../entities/water_goal.dart';

abstract interface class WaterRepository {
  Stream<WaterEntry?> watchEntryForDate(DateTime date);
  Stream<List<WaterEntry>> watchEntriesBetween(DateTime from, DateTime to);
  Future<Result<void>> logWater(DateTime date, int deltaMl);

  Stream<WaterGoal?> watchGoal();
  Future<Result<void>> updateGoal(int dailyGoalMl);
}
