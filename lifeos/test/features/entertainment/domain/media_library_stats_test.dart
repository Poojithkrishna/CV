import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_item.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_status.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_type.dart';
import 'package:lifeos/features/entertainment/domain/services/media_library_stats.dart';

MediaItem _buildItem({
  String id = 'm1',
  MediaStatus status = MediaStatus.wishlist,
  MediaType type = MediaType.movie,
  DateTime? completedDate,
  int currentProgress = 0,
  int? totalProgress,
  double? rating,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return MediaItem(
    id: id,
    title: 'Item $id',
    type: type,
    status: status,
    currentProgress: currentProgress,
    totalProgress: totalProgress,
    rating: rating,
    completedDate: completedDate,
    colorValue: 0xFF8B5CF6,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('MediaLibraryStats.countByStatus', () {
    test('counts every status, including zero-count ones', () {
      final items = [
        _buildItem(id: 'm1', status: MediaStatus.wishlist),
        _buildItem(id: 'm2', status: MediaStatus.wishlist),
        _buildItem(id: 'm3', status: MediaStatus.completed),
      ];

      final counts = MediaLibraryStats.countByStatus(items);

      expect(counts[MediaStatus.wishlist], 2);
      expect(counts[MediaStatus.completed], 1);
      expect(counts[MediaStatus.inProgress], 0);
      expect(counts.length, MediaStatus.values.length);
    });
  });

  group('MediaLibraryStats.countByType', () {
    test('counts every type, including zero-count ones', () {
      final items = [
        _buildItem(id: 'm1', type: MediaType.game),
        _buildItem(id: 'm2', type: MediaType.book),
      ];

      final counts = MediaLibraryStats.countByType(items);

      expect(counts[MediaType.game], 1);
      expect(counts[MediaType.book], 1);
      expect(counts[MediaType.movie], 0);
      expect(counts.length, MediaType.values.length);
    });
  });

  group('MediaLibraryStats.completedSince', () {
    test('includes only items completed on or after the cutoff', () {
      final DateTime cutoff = DateTime(2026, 1, 5);
      final items = [
        _buildItem(id: 'm1', status: MediaStatus.completed, completedDate: DateTime(2026, 1, 5)),
        _buildItem(id: 'm2', status: MediaStatus.completed, completedDate: DateTime(2026, 1, 10)),
        _buildItem(id: 'm3', status: MediaStatus.completed, completedDate: DateTime(2026, 1, 1)),
      ];

      final result = MediaLibraryStats.completedSince(items, cutoff);

      expect(result.map((i) => i.id), containsAll(['m1', 'm2']));
      expect(result.map((i) => i.id), isNot(contains('m3')));
    });

    test('excludes items with no completedDate', () {
      final items = [_buildItem(id: 'm1', status: MediaStatus.inProgress)];
      final result = MediaLibraryStats.completedSince(items, DateTime(2020, 1, 1));
      expect(result, isEmpty);
    });
  });

  group('MediaLibraryStats.progressFraction', () {
    test('divides current by total when a total is set', () {
      final item = _buildItem(currentProgress: 5, totalProgress: 10);
      expect(MediaLibraryStats.progressFraction(item), 0.5);
    });

    test('is null with no total set', () {
      final item = _buildItem(currentProgress: 5, totalProgress: null);
      expect(MediaLibraryStats.progressFraction(item), isNull);
    });

    test('is null with a zero total', () {
      final item = _buildItem(currentProgress: 5, totalProgress: 0);
      expect(MediaLibraryStats.progressFraction(item), isNull);
    });

    test('clamps at 1 when current exceeds total', () {
      final item = _buildItem(currentProgress: 20, totalProgress: 10);
      expect(MediaLibraryStats.progressFraction(item), 1);
    });
  });

  group('MediaLibraryStats.averageRating', () {
    test('averages only the rated items', () {
      final items = [
        _buildItem(id: 'm1', rating: 8),
        _buildItem(id: 'm2', rating: 6),
        _buildItem(id: 'm3', rating: null),
      ];
      expect(MediaLibraryStats.averageRating(items), 7);
    });

    test('is zero when nothing is rated', () {
      final items = [_buildItem(id: 'm1')];
      expect(MediaLibraryStats.averageRating(items), 0);
    });
  });
}
