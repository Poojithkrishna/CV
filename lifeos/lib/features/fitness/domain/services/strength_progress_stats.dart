import '../entities/logged_set.dart';

/// Pure, DB-free strength-progression calculations over a single
/// exercise's full set history — the Strength Progress analytics screen.
class StrengthProgressStats {
  StrengthProgressStats._();

  /// Epley formula: a rough estimate of the heaviest single rep [weight]
  /// at [reps] implies you could lift.
  static double estimatedOneRepMax(double weight, int reps) {
    if (reps <= 0) return weight;
    return weight * (1 + reps / 30);
  }

  /// One point per calendar day — that day's best working (non-warmup)
  /// set's estimated 1RM — oldest first.
  static List<MapEntry<DateTime, double>> oneRepMaxByDate(List<LoggedSet> sets) {
    final Map<DateTime, double> best = {};
    for (final LoggedSet set in sets) {
      if (set.isWarmup) continue;
      final DateTime day = DateTime(set.completedAt.year, set.completedAt.month, set.completedAt.day);
      final double oneRepMax = estimatedOneRepMax(set.weight, set.reps);
      final double? existing = best[day];
      if (existing == null || oneRepMax > existing) {
        best[day] = oneRepMax;
      }
    }
    final List<MapEntry<DateTime, double>> entries = best.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  /// Every PR set, most recent first.
  static List<LoggedSet> personalRecords(List<LoggedSet> sets) {
    final List<LoggedSet> prs = sets.where((s) => s.isPr).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return prs;
  }
}
