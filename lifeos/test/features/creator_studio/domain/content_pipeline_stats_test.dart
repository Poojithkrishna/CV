import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_platform.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_project.dart';
import 'package:lifeos/features/creator_studio/domain/entities/content_stage.dart';
import 'package:lifeos/features/creator_studio/domain/services/content_pipeline_stats.dart';

ContentProject _buildProject({
  String id = 'p1',
  ContentStage stage = ContentStage.idea,
  DateTime? publishedDate,
  int viewCount = 0,
  int likeCount = 0,
  int commentCount = 0,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return ContentProject(
    id: id,
    title: 'Project $id',
    stage: stage,
    platform: ContentPlatform.youtube,
    publishedDate: publishedDate,
    viewCount: viewCount,
    likeCount: likeCount,
    commentCount: commentCount,
    colorValue: 0xFFEC4899,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ContentPipelineStats.countByStage', () {
    test('counts every stage, including zero-count stages', () {
      final projects = [
        _buildProject(id: 'p1', stage: ContentStage.idea),
        _buildProject(id: 'p2', stage: ContentStage.idea),
        _buildProject(id: 'p3', stage: ContentStage.published),
      ];

      final counts = ContentPipelineStats.countByStage(projects);

      expect(counts[ContentStage.idea], 2);
      expect(counts[ContentStage.published], 1);
      expect(counts[ContentStage.recording], 0);
      expect(counts.length, ContentStage.values.length);
    });

    test('is all zero for an empty project list', () {
      final counts = ContentPipelineStats.countByStage(const []);
      expect(counts.values.every((count) => count == 0), isTrue);
    });
  });

  group('ContentPipelineStats.publishedSince', () {
    test('includes only projects published on or after the cutoff', () {
      final DateTime cutoff = DateTime(2026, 1, 5);
      final projects = [
        _buildProject(id: 'p1', stage: ContentStage.published, publishedDate: DateTime(2026, 1, 5)),
        _buildProject(id: 'p2', stage: ContentStage.published, publishedDate: DateTime(2026, 1, 10)),
        _buildProject(id: 'p3', stage: ContentStage.published, publishedDate: DateTime(2026, 1, 1)),
      ];

      final result = ContentPipelineStats.publishedSince(projects, cutoff);

      expect(result.map((p) => p.id), containsAll(['p1', 'p2']));
      expect(result.map((p) => p.id), isNot(contains('p3')));
    });

    test('excludes projects with no publishedDate', () {
      final projects = [_buildProject(id: 'p1', stage: ContentStage.idea)];
      final result = ContentPipelineStats.publishedSince(projects, DateTime(2020, 1, 1));
      expect(result, isEmpty);
    });
  });

  group('ContentPipelineStats totals', () {
    test('sum views, likes and comments across projects', () {
      final projects = [
        _buildProject(id: 'p1', viewCount: 100, likeCount: 10, commentCount: 2),
        _buildProject(id: 'p2', viewCount: 50, likeCount: 5, commentCount: 1),
      ];

      expect(ContentPipelineStats.totalViews(projects), 150);
      expect(ContentPipelineStats.totalLikes(projects), 15);
      expect(ContentPipelineStats.totalComments(projects), 3);
    });
  });

  group('ContentPipelineStats.averageViews', () {
    test('divides total views by project count', () {
      final projects = [
        _buildProject(id: 'p1', viewCount: 100),
        _buildProject(id: 'p2', viewCount: 50),
      ];
      expect(ContentPipelineStats.averageViews(projects), 75);
    });

    test('is zero for an empty list', () {
      expect(ContentPipelineStats.averageViews(const []), 0);
    });
  });
}
