import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/database/app_database.dart';
import 'package:lifeos/features/creator_studio/data/repositories/clip_mapper.dart';
import 'package:lifeos/features/creator_studio/data/repositories/content_goal_mapper.dart';
import 'package:lifeos/features/creator_studio/data/repositories/content_project_mapper.dart';
import 'package:lifeos/features/creator_studio/data/tables/content_goal_table.dart';
import 'package:lifeos/features/creator_studio/domain/entities/clip.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_goal.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_platform.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_project.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_stage.dart';

ContentProject _buildProject({String id = 'p1', int sortOrder = 0}) {
  final DateTime now = DateTime(2026, 1, 1);
  return ContentProject(
    id: id,
    title: 'Project $id',
    stage: ContentStage.idea,
    platform: ContentPlatform.youtube,
    sortOrder: sortOrder,
    colorValue: 0xFFEC4899,
    createdAt: now,
    updatedAt: now,
  );
}

Clip _buildClip(String id, {String? linkedProjectId}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Clip(
    id: id,
    title: 'Clip $id',
    linkedProjectId: linkedProjectId,
    capturedAt: now,
    createdAt: now,
  );
}

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      NativeDatabase.memory(setup: (db) => db.execute('PRAGMA foreign_keys = ON;')),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('watchAllProjects orders by sortOrder', () async {
    await database.contentStudioDao.insertProject(_buildProject(id: 'p2', sortOrder: 2).toCompanion());
    await database.contentStudioDao.insertProject(_buildProject(id: 'p1', sortOrder: 1).toCompanion());

    final projects = await database.contentStudioDao.watchAllProjects().first;

    expect(projects.map((row) => row.id), ['p1', 'p2']);
  });

  test('updateProject persists a stage change', () async {
    await database.contentStudioDao.insertProject(_buildProject().toCompanion());
    final ContentProject stored =
        (await database.contentStudioDao.watchProject('p1').first)!.toDomain();

    await database.contentStudioDao.updateProject(
      stored.copyWith(stage: ContentStage.recording).toCompanion(),
    );

    final ContentProject updated =
        (await database.contentStudioDao.watchProject('p1').first)!.toDomain();
    expect(updated.stage, ContentStage.recording);
  });

  test('deleteProject removes the row', () async {
    await database.contentStudioDao.insertProject(_buildProject().toCompanion());
    await database.contentStudioDao.deleteProject('p1');
    expect(await database.contentStudioDao.watchProject('p1').first, isNull);
  });

  test('deleting a linked project sets the clip\'s linkedProjectId to null', () async {
    await database.contentStudioDao.insertProject(_buildProject().toCompanion());
    await database.contentStudioDao.insertClip(_buildClip('c1', linkedProjectId: 'p1').toCompanion());

    await database.contentStudioDao.deleteProject('p1');

    final Clip? clip = (await database.contentStudioDao.watchClip('c1').first)?.toDomain();
    expect(clip, isNotNull);
    expect(clip!.linkedProjectId, isNull);
  });

  test('watchAllClips orders by capturedAt descending', () async {
    final DateTime earlier = DateTime(2026, 1, 1);
    final DateTime later = DateTime(2026, 1, 10);
    await database.contentStudioDao.insertClip(_buildClip('c1').copyWith(capturedAt: earlier).toCompanion());
    await database.contentStudioDao.insertClip(_buildClip('c2').copyWith(capturedAt: later).toCompanion());

    final clips = await database.contentStudioDao.watchAllClips().first;

    expect(clips.map((row) => row.id), ['c2', 'c1']);
  });

  test('watchGoal is null until a goal row is seeded', () async {
    expect(await database.contentStudioDao.watchGoal().first, isNull);
  });

  test('updateGoal upserts the singleton goal row without a duplicate-key crash', () async {
    await database.contentStudioDao.updateGoal(3);
    ContentGoal? goal = (await database.contentStudioDao.watchGoal().first)?.toDomain();
    expect(goal?.weeklyUploadTarget, 3);

    await database.contentStudioDao.updateGoal(7);
    goal = (await database.contentStudioDao.watchGoal().first)?.toDomain();
    expect(goal?.weeklyUploadTarget, 7);
  });

  test('the seeded default goal id matches kDefaultContentGoalId', () async {
    await database.contentStudioDao.updateGoal(5);
    final goalRow = await (database.select(database.contentGoals)
          ..where((tbl) => tbl.id.equals(kDefaultContentGoalId)))
        .getSingleOrNull();
    expect(goalRow, isNotNull);
  });
}
