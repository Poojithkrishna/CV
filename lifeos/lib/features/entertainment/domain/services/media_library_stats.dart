import '../entities/media_item.dart';
import '../entities/media_status.dart';
import '../entities/media_type.dart';

/// Pure, DB-free aggregation over already-loaded media items — the
/// Entertainment home hub and library screen.
class MediaLibraryStats {
  MediaLibraryStats._();

  static Map<MediaStatus, int> countByStatus(List<MediaItem> items) {
    final Map<MediaStatus, int> counts = {for (final status in MediaStatus.values) status: 0};
    for (final MediaItem item in items) {
      counts[item.status] = (counts[item.status] ?? 0) + 1;
    }
    return counts;
  }

  static Map<MediaType, int> countByType(List<MediaItem> items) {
    final Map<MediaType, int> counts = {for (final type in MediaType.values) type: 0};
    for (final MediaItem item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Completed items with a `completedDate` on or after [since].
  static List<MediaItem> completedSince(List<MediaItem> items, DateTime since) {
    return items
        .where((item) => item.completedDate != null && !item.completedDate!.isBefore(since))
        .toList(growable: false);
  }

  /// Fraction of [currentProgress]/[totalProgress] for one item, clamped
  /// to [0, 1]. Null when there's no known total to measure against.
  static double? progressFraction(MediaItem item) {
    final int? total = item.totalProgress;
    if (total == null || total <= 0) return null;
    final double fraction = item.currentProgress / total;
    if (fraction < 0) return 0;
    if (fraction > 1) return 1;
    return fraction;
  }

  /// Average of every non-null rating across [items]. Zero if none are
  /// rated yet.
  static double averageRating(List<MediaItem> items) {
    final List<double> rated = [
      for (final item in items)
        if (item.rating != null) item.rating!,
    ];
    if (rated.isEmpty) return 0;
    return rated.reduce((a, b) => a + b) / rated.length;
  }
}
