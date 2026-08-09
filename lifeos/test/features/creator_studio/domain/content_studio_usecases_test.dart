import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/creator_studio/domain/entities/clip.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_goal.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_platform.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_project.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_stage.dart';
import 'package:lifeos/features/creator_studio/domain/repositories/content_studio_repository.dart';
import 'package:lifeos/features/creator_studio/domain/usecases/create_clip.dart';
import 'package:lifeos/features/creator_studio/domain/usecases/create_content_project.dart';
import 'package:lifeos/features/creator_studio/domain/usecases/move_project_to_stage.dart';
import 'package:lifeos/features/creator_studio/domain/usecases/update_content_goal.dart';

class _FakeContentStudioRepository implements ContentStudioRepository {
  ContentProject? savedProject;
  Clip? savedClip;
  int? savedWeeklyTarget;

  @override
  Future<Result<ContentProject>> createProject(ContentProject project) async {
    savedProject = project;
    return Result.ok(project);
  }

  @override
  Future<Result<ContentProject>> updateProject(ContentProject project) async {
    savedProject = project;
    return Result.ok(project);
  }

  @override
  Future<Result<void>> deleteProject(String id) async => const Result.ok(null);

  @override
  Stream<ContentProject?> watchProject(String id) => const Stream.empty();

  @override
  Stream<List<ContentProject>> watchAllProjects() => const Stream.empty();

  @override
  Future<Result<Clip>> createClip(Clip clip) async {
    savedClip = clip;
    return Result.ok(clip);
  }

  @override
  Future<Result<Clip>> updateClip(Clip clip) async {
    savedClip = clip;
    return Result.ok(clip);
  }

  @override
  Future<Result<void>> deleteClip(String id) async => const Result.ok(null);

  @override
  Stream<Clip?> watchClip(String id) => const Stream.empty();

  @override
  Stream<List<Clip>> watchAllClips() => const Stream.empty();

  @override
  Stream<ContentGoal?> watchGoal() => const Stream.empty();

  @override
  Future<Result<void>> updateGoal(int weeklyUploadTarget) async {
    savedWeeklyTarget = weeklyUploadTarget;
    return const Result.ok(null);
  }
}

ContentProject _buildProject({
  String id = 'p1',
  ContentStage stage = ContentStage.idea,
  DateTime? publishedDate,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return ContentProject(
    id: id,
    title: 'My video',
    stage: stage,
    platform: ContentPlatform.youtube,
    publishedDate: publishedDate,
    colorValue: 0xFFEC4899,
    createdAt: now,
    updatedAt: now,
  );
}

Clip _buildClip({String title = 'Best play'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Clip(id: 'c1', title: title, capturedAt: now, createdAt: now);
}

void main() {
  group('CreateContentProject', () {
    test('persists a project with a non-blank title', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = CreateContentProject(repo);

      final result = await useCase(_buildProject());

      expect(result.isOk, isTrue);
      expect(repo.savedProject?.title, 'My video');
    });

    test('rejects a blank title', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = CreateContentProject(repo);

      final result = await useCase(_buildProject().copyWith(title: '   '));

      expect(result.isErr, isTrue);
      expect(repo.savedProject, isNull);
    });
  });

  group('CreateClip', () {
    test('persists a clip with a non-blank title', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = CreateClip(repo);

      final result = await useCase(_buildClip());

      expect(result.isOk, isTrue);
      expect(repo.savedClip?.title, 'Best play');
    });

    test('rejects a blank title', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = CreateClip(repo);

      final result = await useCase(_buildClip(title: '  '));

      expect(result.isErr, isTrue);
      expect(repo.savedClip, isNull);
    });
  });

  group('UpdateContentGoal', () {
    test('persists a positive weekly target', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = UpdateContentGoal(repo);

      final result = await useCase(5);

      expect(result.isOk, isTrue);
      expect(repo.savedWeeklyTarget, 5);
    });

    test('rejects a zero target', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = UpdateContentGoal(repo);

      final result = await useCase(0);

      expect(result.isErr, isTrue);
      expect(repo.savedWeeklyTarget, isNull);
    });

    test('rejects a negative target', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = UpdateContentGoal(repo);

      final result = await useCase(-3);

      expect(result.isErr, isTrue);
      expect(repo.savedWeeklyTarget, isNull);
    });
  });

  group('MoveProjectToStage', () {
    test('stamps publishedDate the first time a project reaches Published', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = MoveProjectToStage(repo);
      final project = _buildProject(stage: ContentStage.upload);

      final result = await useCase(project, ContentStage.published);

      expect(result.isOk, isTrue);
      expect(repo.savedProject?.stage, ContentStage.published);
      expect(repo.savedProject?.publishedDate, isNotNull);
    });

    test('never overwrites an existing publishedDate when reopened and republished', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = MoveProjectToStage(repo);
      final DateTime originalPublish = DateTime(2025, 12, 1);
      final project = _buildProject(stage: ContentStage.published, publishedDate: originalPublish);

      final backToEditing = await useCase(project, ContentStage.editing);
      expect(backToEditing.isOk, isTrue);
      expect(repo.savedProject?.publishedDate, originalPublish);

      final rePublished = await useCase(repo.savedProject!, ContentStage.published);
      expect(rePublished.isOk, isTrue);
      expect(repo.savedProject?.publishedDate, originalPublish);
    });

    test('leaves publishedDate untouched when moving between non-published stages', () async {
      final repo = _FakeContentStudioRepository();
      final useCase = MoveProjectToStage(repo);
      final project = _buildProject(stage: ContentStage.idea);

      await useCase(project, ContentStage.recording);

      expect(repo.savedProject?.stage, ContentStage.recording);
      expect(repo.savedProject?.publishedDate, isNull);
    });
  });
}
