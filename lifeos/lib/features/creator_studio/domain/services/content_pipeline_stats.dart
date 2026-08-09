import '../entities/content_project.dart';
import '../entities/content_stage.dart';

/// Pure, DB-free aggregation over already-loaded projects — the Creator
/// Studio home hub and Analytics screen.
class ContentPipelineStats {
  ContentPipelineStats._();

  static Map<ContentStage, int> countByStage(List<ContentProject> projects) {
    final Map<ContentStage, int> counts = {for (final stage in ContentStage.values) stage: 0};
    for (final ContentProject project in projects) {
      counts[project.stage] = (counts[project.stage] ?? 0) + 1;
    }
    return counts;
  }

  /// Published projects with a `publishedDate` on or after [since].
  static List<ContentProject> publishedSince(List<ContentProject> projects, DateTime since) {
    return projects
        .where((p) => p.publishedDate != null && !p.publishedDate!.isBefore(since))
        .toList(growable: false);
  }

  static int totalViews(List<ContentProject> projects) {
    return projects.fold<int>(0, (sum, p) => sum + p.viewCount);
  }

  static int totalLikes(List<ContentProject> projects) {
    return projects.fold<int>(0, (sum, p) => sum + p.likeCount);
  }

  static int totalComments(List<ContentProject> projects) {
    return projects.fold<int>(0, (sum, p) => sum + p.commentCount);
  }

  static double averageViews(List<ContentProject> publishedProjects) {
    if (publishedProjects.isEmpty) return 0;
    return totalViews(publishedProjects) / publishedProjects.length;
  }
}
