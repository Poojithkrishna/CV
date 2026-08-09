import '../../../../core/utils/result.dart';
import '../entities/content_project.dart';
import '../entities/content_stage.dart';
import '../repositories/content_studio_repository.dart';

/// Moves a project to a new pipeline stage. Moving into
/// [ContentStage.published] for the first time stamps `publishedDate` —
/// moving back out of it (e.g. to fix something) never clears that
/// stamp, so "first published" stays accurate even if the project is
/// later reopened for edits.
class MoveProjectToStage {
  MoveProjectToStage(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<ContentProject>> call(ContentProject project, ContentStage newStage) {
    final ContentProject updated = project.copyWith(
      stage: newStage,
      publishedDate: newStage == ContentStage.published
          ? (project.publishedDate ?? DateTime.now())
          : project.publishedDate,
      updatedAt: DateTime.now(),
    );
    return _repository.updateProject(updated);
  }
}
