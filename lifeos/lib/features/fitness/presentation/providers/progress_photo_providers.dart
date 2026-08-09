import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/progress_photos_dao.dart';
import '../../data/repositories/progress_photo_repository_impl.dart';
import '../../domain/entities/photo_category.dart';
import '../../domain/entities/progress_photo.dart';
import '../../domain/repositories/progress_photo_repository.dart';
import '../../domain/usecases/add_progress_photo.dart';
import '../../domain/usecases/delete_progress_photo.dart';

final Provider<ProgressPhotosDao> progressPhotosDaoProvider = Provider<ProgressPhotosDao>((ref) {
  return ProgressPhotosDao(ref.watch(appDatabaseProvider));
});

final Provider<ProgressPhotoRepository> progressPhotoRepositoryProvider =
    Provider<ProgressPhotoRepository>((ref) {
  return ProgressPhotoRepositoryImpl(ref.watch(progressPhotosDaoProvider));
});

final Provider<AddProgressPhoto> addProgressPhotoUseCaseProvider = Provider(
  (ref) => AddProgressPhoto(ref.watch(progressPhotoRepositoryProvider)),
);
final Provider<DeleteProgressPhoto> deleteProgressPhotoUseCaseProvider = Provider(
  (ref) => DeleteProgressPhoto(ref.watch(progressPhotoRepositoryProvider)),
);

final StreamProvider<List<ProgressPhoto>> allProgressPhotosProvider =
    StreamProvider<List<ProgressPhoto>>((ref) {
  return ref.watch(progressPhotoRepositoryProvider).watchAllPhotos();
});

final StreamProviderFamily<List<ProgressPhoto>, PhotoCategory> photosByCategoryProvider =
    StreamProvider.family<List<ProgressPhoto>, PhotoCategory>((ref, category) {
  return ref.watch(progressPhotoRepositoryProvider).watchPhotosByCategory(category);
});
