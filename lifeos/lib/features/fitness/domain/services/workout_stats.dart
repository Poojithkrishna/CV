import '../entities/logged_set.dart';

/// Pure, DB-free calculations shared by the workout tracker: session
/// volume and next-session weight suggestions. Kept out of the
/// repository/DAO layer since neither needs a database — they're just
/// arithmetic over sets already in hand.
class WorkoutStats {
  WorkoutStats._();

  /// Total working weight moved across [sets] — reps × weight, summed,
  /// excluding warmups.
  static double sessionVolume(Iterable<LoggedSet> sets) {
    return sets.fold(0.0, (double sum, LoggedSet set) => sum + set.volume);
  }

  /// Suggests a weight for the next time this exercise is trained: if the
  /// last working set met or exceeded the target rep count, suggest
  /// nudging the weight up by [increment]; otherwise suggest repeating
  /// the same weight until reps are met. Returns null with no prior
  /// performance to base a suggestion on.
  static double? suggestNextWeight({
    required double? previousWeight,
    required int? previousReps,
    required String targetReps,
    double increment = 2.5,
  }) {
    if (previousWeight == null || previousReps == null) return null;
    final int? target = _parseTargetReps(targetReps);
    if (target == null) return previousWeight;
    return previousReps >= target ? previousWeight + increment : previousWeight;
  }

  /// Pulls the first number out of a free-form target-reps string like
  /// `"8-12"` or `"10"`.
  static int? _parseTargetReps(String targetReps) {
    final RegExpMatch? match = RegExp(r'\d+').firstMatch(targetReps);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }
}
