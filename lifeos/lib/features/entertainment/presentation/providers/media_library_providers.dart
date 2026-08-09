import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/media_library_dao.dart';
import '../../data/repositories/media_library_repository_impl.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_library_repository.dart';
import '../../domain/usecases/create_media_item.dart';
import '../../domain/usecases/delete_media_item.dart';
import '../../domain/usecases/log_media_progress.dart';
import '../../domain/usecases/update_media_item.dart';
import '../../domain/usecases/update_media_status.dart';

final Provider<MediaLibraryDao> mediaLibraryDaoProvider = Provider<MediaLibraryDao>((ref) {
  return MediaLibraryDao(ref.watch(appDatabaseProvider));
});

final Provider<MediaLibraryRepository> mediaLibraryRepositoryProvider =
    Provider<MediaLibraryRepository>((ref) {
  return MediaLibraryRepositoryImpl(ref.watch(mediaLibraryDaoProvider));
});

final Provider<CreateMediaItem> createMediaItemUseCaseProvider = Provider(
  (ref) => CreateMediaItem(ref.watch(mediaLibraryRepositoryProvider)),
);
final Provider<UpdateMediaItem> updateMediaItemUseCaseProvider = Provider(
  (ref) => UpdateMediaItem(ref.watch(mediaLibraryRepositoryProvider)),
);
final Provider<DeleteMediaItem> deleteMediaItemUseCaseProvider = Provider(
  (ref) => DeleteMediaItem(ref.watch(mediaLibraryRepositoryProvider)),
);
final Provider<UpdateMediaStatus> updateMediaStatusUseCaseProvider = Provider(
  (ref) => UpdateMediaStatus(ref.watch(mediaLibraryRepositoryProvider)),
);
final Provider<LogMediaProgress> logMediaProgressUseCaseProvider = Provider(
  (ref) => LogMediaProgress(ref.watch(mediaLibraryRepositoryProvider)),
);

final StreamProvider<List<MediaItem>> allMediaItemsProvider = StreamProvider<List<MediaItem>>((ref) {
  return ref.watch(mediaLibraryRepositoryProvider).watchAllItems();
});

final StreamProviderFamily<MediaItem?, String> mediaItemByIdProvider =
    StreamProvider.family<MediaItem?, String>((ref, id) {
  return ref.watch(mediaLibraryRepositoryProvider).watchItem(id);
});
