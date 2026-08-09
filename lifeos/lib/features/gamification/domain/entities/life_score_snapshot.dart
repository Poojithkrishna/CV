import 'package:flutter/foundation.dart';

import 'rank.dart';

/// A single day's recorded Life Score, XP and rank — the one thing this
/// module persists that isn't purely a live computation, so the history
/// chart has something to plot. See `LifeScoreSnapshots` for why this is
/// "last value seen that day," not a true continuous recording.
@immutable
class LifeScoreSnapshot {
  const LifeScoreSnapshot({
    required this.id,
    required this.date,
    required this.lifeScore,
    required this.xp,
    required this.rank,
  });

  final String id;
  final DateTime date;
  final double lifeScore;
  final int xp;
  final Rank rank;
}
