import '../entities/measurement_entry.dart';

/// Pure, DB-free trend calculation shared by the measurement detail
/// screen — the same "change over the last N days" idea as
/// `BodyWeightStats`, kept separate since it operates on a per-type
/// entry list rather than a single global series.
class MeasurementStats {
  MeasurementStats._();

  static double? changeOverDays({
    required List<MeasurementEntry> entriesAscending,
    required int days,
    required DateTime asOf,
  }) {
    if (entriesAscending.length < 2) return null;

    final MeasurementEntry latest = entriesAscending.last;
    final DateTime cutoff = DateTime(asOf.year, asOf.month, asOf.day).subtract(Duration(days: days));

    MeasurementEntry baseline = entriesAscending.first;
    for (final MeasurementEntry entry in entriesAscending) {
      if (entry.date.isAfter(cutoff)) break;
      baseline = entry;
    }
    if (baseline.id == latest.id) return null;
    return latest.valueCm - baseline.valueCm;
  }
}
