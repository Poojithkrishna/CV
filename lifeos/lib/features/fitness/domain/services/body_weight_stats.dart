import '../entities/body_weight_entry.dart';

/// Pure, DB-free trend calculations shared by the body weight list and
/// chart screens. [entriesAscending] is always expected sorted oldest to
/// newest, matching what `BodyWeightDao.watchAllEntries` returns.
class BodyWeightStats {
  BodyWeightStats._();

  /// The change from the closest entry at or before `asOf - days` to the
  /// most recent entry — `null` with fewer than two entries to compare.
  static double? changeOverDays({
    required List<BodyWeightEntry> entriesAscending,
    required int days,
    required DateTime asOf,
  }) {
    if (entriesAscending.length < 2) return null;

    final BodyWeightEntry latest = entriesAscending.last;
    final DateTime cutoff = DateTime(asOf.year, asOf.month, asOf.day).subtract(Duration(days: days));

    BodyWeightEntry baseline = entriesAscending.first;
    for (final BodyWeightEntry entry in entriesAscending) {
      if (entry.date.isAfter(cutoff)) break;
      baseline = entry;
    }
    if (baseline.id == latest.id) return null;
    return latest.weightKg - baseline.weightKg;
  }
}
