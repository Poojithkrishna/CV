import '../entities/recovery_entry.dart';

/// Pure, DB-free composite recovery score (0-100) shared by the Recovery
/// screen — averages whichever of sleep/soreness/stress were actually
/// logged that day, rather than requiring all three.
class RecoveryStats {
  RecoveryStats._();

  static const double _targetSleepHours = 8;

  static double? score(RecoveryEntry entry) {
    final List<double> components = [];

    if (entry.sleepHours != null) {
      components.add((entry.sleepHours! / _targetSleepHours).clamp(0, 1).toDouble() * 100);
    }
    if (entry.sorenessLevel != null) {
      components.add((5 - entry.sorenessLevel!) / 4 * 100);
    }
    if (entry.stressLevel != null) {
      components.add((5 - entry.stressLevel!) / 4 * 100);
    }

    if (components.isEmpty) return null;
    return components.reduce((a, b) => a + b) / components.length;
  }
}
