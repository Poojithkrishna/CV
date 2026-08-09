import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_item.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_status.dart';
import 'package:lifeos/features/entertainment/domain/entities/media_type.dart';
import 'package:lifeos/features/entertainment/domain/repositories/media_library_repository.dart';
import 'package:lifeos/features/entertainment/domain/usecases/create_media_item.dart';
import 'package:lifeos/features/entertainment/domain/usecases/log_media_progress.dart';
import 'package:lifeos/features/entertainment/domain/usecases/update_media_status.dart';

class _FakeMediaLibraryRepository implements MediaLibraryRepository {
  MediaItem? savedItem;
  String? adjustedId;
  int? adjustedDelta;

  @override
  Future<Result<MediaItem>> createItem(MediaItem item) async {
    savedItem = item;
    return Result.ok(item);
  }

  @override
  Future<Result<MediaItem>> updateItem(MediaItem item) async {
    savedItem = item;
    return Result.ok(item);
  }

  @override
  Future<Result<void>> deleteItem(String id) async => const Result.ok(null);

  @override
  Stream<MediaItem?> watchItem(String id) => const Stream.empty();

  @override
  Stream<List<MediaItem>> watchAllItems() => const Stream.empty();

  @override
  Future<Result<void>> adjustProgress(String id, int delta) async {
    adjustedId = id;
    adjustedDelta = delta;
    return const Result.ok(null);
  }
}

MediaItem _buildItem({
  String id = 'm1',
  MediaStatus status = MediaStatus.wishlist,
  DateTime? startedDate,
  DateTime? completedDate,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return MediaItem(
    id: id,
    title: 'Some show',
    type: MediaType.series,
    status: status,
    startedDate: startedDate,
    completedDate: completedDate,
    colorValue: 0xFF8B5CF6,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateMediaItem', () {
    test('persists an item with a non-blank title', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = CreateMediaItem(repo);

      final result = await useCase(_buildItem());

      expect(result.isOk, isTrue);
      expect(repo.savedItem?.title, 'Some show');
    });

    test('rejects a blank title', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = CreateMediaItem(repo);

      final result = await useCase(_buildItem().copyWith(title: '   '));

      expect(result.isErr, isTrue);
      expect(repo.savedItem, isNull);
    });
  });

  group('UpdateMediaStatus', () {
    test('stamps startedDate the first time an item reaches In Progress', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = UpdateMediaStatus(repo);
      final item = _buildItem(status: MediaStatus.wishlist);

      final result = await useCase(item, MediaStatus.inProgress);

      expect(result.isOk, isTrue);
      expect(repo.savedItem?.status, MediaStatus.inProgress);
      expect(repo.savedItem?.startedDate, isNotNull);
      expect(repo.savedItem?.completedDate, isNull);
    });

    test('stamps completedDate the first time an item reaches Completed', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = UpdateMediaStatus(repo);
      final item = _buildItem(status: MediaStatus.inProgress, startedDate: DateTime(2025, 12, 1));

      final result = await useCase(item, MediaStatus.completed);

      expect(result.isOk, isTrue);
      expect(repo.savedItem?.completedDate, isNotNull);
      expect(repo.savedItem?.startedDate, DateTime(2025, 12, 1));
    });

    test('never overwrites an existing startedDate or completedDate', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = UpdateMediaStatus(repo);
      final DateTime originalStart = DateTime(2025, 11, 1);
      final DateTime originalComplete = DateTime(2025, 12, 1);
      final item = _buildItem(
        status: MediaStatus.completed,
        startedDate: originalStart,
        completedDate: originalComplete,
      );

      final droppedThenResumed = await useCase(item, MediaStatus.dropped);
      expect(droppedThenResumed.isOk, isTrue);
      expect(repo.savedItem?.startedDate, originalStart);
      expect(repo.savedItem?.completedDate, originalComplete);

      final recompleted = await useCase(repo.savedItem!, MediaStatus.completed);
      expect(recompleted.isOk, isTrue);
      expect(repo.savedItem?.startedDate, originalStart);
      expect(repo.savedItem?.completedDate, originalComplete);
    });

    test('leaves both dates untouched moving between non-triggering statuses', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = UpdateMediaStatus(repo);
      final item = _buildItem(status: MediaStatus.wishlist);

      await useCase(item, MediaStatus.dropped);

      expect(repo.savedItem?.status, MediaStatus.dropped);
      expect(repo.savedItem?.startedDate, isNull);
      expect(repo.savedItem?.completedDate, isNull);
    });
  });

  group('LogMediaProgress', () {
    test('forwards the id and delta to the repository', () async {
      final repo = _FakeMediaLibraryRepository();
      final useCase = LogMediaProgress(repo);

      final result = await useCase('m1', 1);

      expect(result.isOk, isTrue);
      expect(repo.adjustedId, 'm1');
      expect(repo.adjustedDelta, 1);
    });
  });
}
