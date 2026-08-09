import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/entities/water_goal.dart';
import '../../domain/repositories/water_repository.dart';
import '../daos/water_dao.dart';
import 'water_mapper.dart';

class WaterRepositoryImpl implements WaterRepository {
  WaterRepositoryImpl(this._dao);

  final WaterDao _dao;

  @override
  Stream<WaterEntry?> watchEntryForDate(DateTime date) {
    return _dao.watchEntryForDate(date).map((row) => row?.toDomain());
  }

  @override
  Stream<List<WaterEntry>> watchEntriesBetween(DateTime from, DateTime to) {
    return _dao
        .watchEntriesBetween(from, to)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<void>> logWater(DateTime date, int deltaMl) async {
    try {
      await _dao.logWater(date, deltaMl);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not log water: $e'));
    }
  }

  @override
  Stream<WaterGoal?> watchGoal() {
    return _dao.watchGoal().map((row) => row?.toDomain());
  }

  @override
  Future<Result<void>> updateGoal(int dailyGoalMl) async {
    try {
      await _dao.updateGoal(dailyGoalMl);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update goal: $e'));
    }
  }
}
