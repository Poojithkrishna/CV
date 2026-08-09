import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/clips_table.dart';
import '../tables/content_goal_table.dart';
import '../tables/content_projects_table.dart';

part 'content_studio_dao.g.dart';

@DriftAccessor(tables: [ContentProjects, Clips, ContentGoals])
class ContentStudioDao extends DatabaseAccessor<AppDatabase> with _$ContentStudioDaoMixin {
  ContentStudioDao(super.db);

  // --- Projects ---

  Stream<List<ContentProjectRow>> watchAllProjects() {
    return (select(contentProjects)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .watch();
  }

  Stream<ContentProjectRow?> watchProject(String id) {
    return (select(contentProjects)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertProject(ContentProjectsCompanion entry) {
    return into(contentProjects).insert(entry);
  }

  Future<bool> updateProject(ContentProjectsCompanion entry) {
    return update(contentProjects).replace(entry);
  }

  Future<int> deleteProject(String id) {
    return (delete(contentProjects)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Clips ---

  Stream<List<ClipRow>> watchAllClips() {
    return (select(clips)..orderBy([(tbl) => OrderingTerm.desc(tbl.capturedAt)])).watch();
  }

  Stream<ClipRow?> watchClip(String id) {
    return (select(clips)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> insertClip(ClipsCompanion entry) {
    return into(clips).insert(entry);
  }

  Future<bool> updateClip(ClipsCompanion entry) {
    return update(clips).replace(entry);
  }

  Future<int> deleteClip(String id) {
    return (delete(clips)..where((tbl) => tbl.id.equals(id))).go();
  }

  // --- Goal ---

  Stream<ContentGoalRow?> watchGoal() {
    return (select(contentGoals)..where((tbl) => tbl.id.equals(kDefaultContentGoalId)))
        .watchSingleOrNull();
  }

  Future<void> updateGoal(int weeklyUploadTarget) {
    return into(contentGoals).insertOnConflictUpdate(
      ContentGoalsCompanion.insert(
        id: kDefaultContentGoalId,
        weeklyUploadTarget: Value(weeklyUploadTarget),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
