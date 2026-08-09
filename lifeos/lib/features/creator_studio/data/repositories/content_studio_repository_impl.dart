import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/clip.dart';
import '../../domain/entities/content_goal.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/repositories/content_studio_repository.dart';
import '../daos/content_studio_dao.dart';
import 'clip_mapper.dart';
import 'content_goal_mapper.dart';
import 'content_project_mapper.dart';

class ContentStudioRepositoryImpl implements ContentStudioRepository {
  ContentStudioRepositoryImpl(this._dao);

  final ContentStudioDao _dao;

  @override
  Stream<List<ContentProject>> watchAllProjects() {
    return _dao
        .watchAllProjects()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<ContentProject?> watchProject(String id) {
    return _dao.watchProject(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<ContentProject>> createProject(ContentProject project) async {
    try {
      await _dao.insertProject(project.toCompanion());
      return Result.ok(project);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save project: $e'));
    }
  }

  @override
  Future<Result<ContentProject>> updateProject(ContentProject project) async {
    try {
      final bool updated = await _dao.updateProject(project.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Project no longer exists.'));
      }
      return Result.ok(project);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update project: $e'));
    }
  }

  @override
  Future<Result<void>> deleteProject(String id) async {
    try {
      await _dao.deleteProject(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete project: $e'));
    }
  }

  @override
  Stream<List<Clip>> watchAllClips() {
    return _dao
        .watchAllClips()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Clip?> watchClip(String id) {
    return _dao.watchClip(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Clip>> createClip(Clip clip) async {
    try {
      await _dao.insertClip(clip.toCompanion());
      return Result.ok(clip);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save clip: $e'));
    }
  }

  @override
  Future<Result<Clip>> updateClip(Clip clip) async {
    try {
      final bool updated = await _dao.updateClip(clip.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Clip no longer exists.'));
      }
      return Result.ok(clip);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update clip: $e'));
    }
  }

  @override
  Future<Result<void>> deleteClip(String id) async {
    try {
      await _dao.deleteClip(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete clip: $e'));
    }
  }

  @override
  Stream<ContentGoal?> watchGoal() {
    return _dao.watchGoal().map((row) => row?.toDomain());
  }

  @override
  Future<Result<void>> updateGoal(int weeklyUploadTarget) async {
    try {
      await _dao.updateGoal(weeklyUploadTarget);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update goal: $e'));
    }
  }
}
