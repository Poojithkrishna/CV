import 'package:flutter/foundation.dart';

import 'attribute.dart';
import 'rank.dart';

/// The fully-computed cultivation state at a point in time — everything
/// `GamificationStats` derives from the live cross-module snapshot, in
/// one bundle so the home screen and dashboard tile don't each recompute
/// it separately.
@immutable
class GamificationSnapshot {
  const GamificationSnapshot({
    required this.attributes,
    required this.xp,
    required this.rank,
    required this.progressToNextRank,
    required this.lifeScore,
    required this.satisfiedAchievementKeys,
  });

  final Map<Attribute, double> attributes;
  final int xp;
  final Rank rank;

  /// 0-1 progress from [rank] toward the next rank; 1.0 once at the max
  /// rank.
  final double progressToNextRank;

  final double lifeScore;
  final Set<String> satisfiedAchievementKeys;
}
