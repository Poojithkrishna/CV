import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/content_studio_dao.dart';
import '../../data/repositories/content_studio_repository_impl.dart';
import '../../domain/entities/clip.dart';
import '../../domain/entities/content_goal.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/repositories/content_studio_repository.dart';
import '../../domain/usecases/create_clip.dart';
import '../../domain/usecases/create_content_project.dart';
import '../../domain/usecases/delete_clip.dart';
import '../../domain/usecases/delete_content_project.dart';
import '../../domain/usecases/move_project_to_stage.dart';
import '../../domain/usecases/update_clip.dart';
import '../../domain/usecases/update_content_goal.dart';
import '../../domain/usecases/update_content_project.dart';

final Provider<ContentStudioDao> contentStudioDaoProvider = Provider<ContentStudioDao>((ref) {
  return ContentStudioDao(ref.watch(appDatabaseProvider));
});

final Provider<ContentStudioRepository> contentStudioRepositoryProvider =
    Provider<ContentStudioRepository>((ref) {
  return ContentStudioRepositoryImpl(ref.watch(contentStudioDaoProvider));
});

final Provider<CreateContentProject> createContentProjectUseCaseProvider = Provider(
  (ref) => CreateContentProject(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<UpdateContentProject> updateContentProjectUseCaseProvider = Provider(
  (ref) => UpdateContentProject(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<DeleteContentProject> deleteContentProjectUseCaseProvider = Provider(
  (ref) => DeleteContentProject(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<MoveProjectToStage> moveProjectToStageUseCaseProvider = Provider(
  (ref) => MoveProjectToStage(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<CreateClip> createClipUseCaseProvider = Provider(
  (ref) => CreateClip(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<UpdateClip> updateClipUseCaseProvider = Provider(
  (ref) => UpdateClip(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<DeleteClip> deleteClipUseCaseProvider = Provider(
  (ref) => DeleteClip(ref.watch(contentStudioRepositoryProvider)),
);
final Provider<UpdateContentGoal> updateContentGoalUseCaseProvider = Provider(
  (ref) => UpdateContentGoal(ref.watch(contentStudioRepositoryProvider)),
);

final StreamProvider<List<ContentProject>> allContentProjectsProvider =
    StreamProvider<List<ContentProject>>((ref) {
  return ref.watch(contentStudioRepositoryProvider).watchAllProjects();
});

final StreamProviderFamily<ContentProject?, String> contentProjectByIdProvider =
    StreamProvider.family<ContentProject?, String>((ref, id) {
  return ref.watch(contentStudioRepositoryProvider).watchProject(id);
});

final StreamProvider<List<Clip>> allClipsProvider = StreamProvider<List<Clip>>((ref) {
  return ref.watch(contentStudioRepositoryProvider).watchAllClips();
});

final StreamProviderFamily<Clip?, String> clipByIdProvider =
    StreamProvider.family<Clip?, String>((ref, id) {
  return ref.watch(contentStudioRepositoryProvider).watchClip(id);
});

final StreamProvider<ContentGoal?> contentGoalProvider = StreamProvider<ContentGoal?>((ref) {
  return ref.watch(contentStudioRepositoryProvider).watchGoal();
});
