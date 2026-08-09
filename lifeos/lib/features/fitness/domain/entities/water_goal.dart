import 'package:flutter/foundation.dart';

@immutable
class WaterGoal {
  const WaterGoal({required this.dailyGoalMl, required this.updatedAt});

  final int dailyGoalMl;
  final DateTime updatedAt;
}
