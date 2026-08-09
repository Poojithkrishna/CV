import '../../../../core/utils/result.dart';
import '../entities/clip.dart';
import '../entities/content_goal.dart';
import '../entities/content_project.dart';

abstract interface class ContentStudioRepository {
  Stream<List<ContentProject>> watchAllProjects();
  Stream<ContentProject?> watchProject(String id);
  Future<Result<ContentProject>> createProject(ContentProject project);
  Future<Result<ContentProject>> updateProject(ContentProject project);
  Future<Result<void>> deleteProject(String id);

  Stream<List<Clip>> watchAllClips();
  Stream<Clip?> watchClip(String id);
  Future<Result<Clip>> createClip(Clip clip);
  Future<Result<Clip>> updateClip(Clip clip);
  Future<Result<void>> deleteClip(String id);

  Stream<ContentGoal?> watchGoal();
  Future<Result<void>> updateGoal(int weeklyUploadTarget);
}
