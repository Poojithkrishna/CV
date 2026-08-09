import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/water_dao.dart';
import '../../data/repositories/water_repository_impl.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/entities/water_goal.dart';
import '../../domain/repositories/water_repository.dart';
import '../../domain/usecases/log_water.dart';
import '../../domain/usecases/update_water_goal.dart';

final Provider<WaterDao> waterDaoProvider = Provider<WaterDao>((ref) {
  return WaterDao(ref.watch(appDatabaseProvider));
});

final Provider<WaterRepository> waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepositoryImpl(ref.watch(waterDaoProvider));
});

final Provider<LogWater> logWaterUseCaseProvider = Provider(
  (ref) => LogWater(ref.watch(waterRepositoryProvider)),
);
final Provider<UpdateWaterGoal> updateWaterGoalUseCaseProvider = Provider(
  (ref) => UpdateWaterGoal(ref.watch(waterRepositoryProvider)),
);

DateTime _normalizeDay(DateTime date) => DateTime(date.year, date.month, date.day);

final StreamProviderFamily<WaterEntry?, DateTime> waterEntryForDateProvider =
    StreamProvider.family<WaterEntry?, DateTime>((ref, date) {
  return ref.watch(waterRepositoryProvider).watchEntryForDate(_normalizeDay(date));
});

final StreamProvider<WaterEntry?> todayWaterEntryProvider = StreamProvider<WaterEntry?>((ref) {
  return ref.watch(waterRepositoryProvider).watchEntryForDate(_normalizeDay(DateTime.now()));
});

/// The last 7 days (inclusive of today), oldest first — used for the
/// weekly bar chart.
final StreamProvider<List<WaterEntry>> weeklyWaterEntriesProvider =
    StreamProvider<List<WaterEntry>>((ref) {
  final DateTime today = _normalizeDay(DateTime.now());
  final DateTime weekAgo = today.subtract(const Duration(days: 6));
  return ref.watch(waterRepositoryProvider).watchEntriesBetween(weekAgo, today);
});

final StreamProvider<WaterGoal?> waterGoalProvider = StreamProvider<WaterGoal?>((ref) {
  return ref.watch(waterRepositoryProvider).watchGoal();
});
