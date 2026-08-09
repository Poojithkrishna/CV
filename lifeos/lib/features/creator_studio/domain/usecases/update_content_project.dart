import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/content_project.dart';
import '../repositories/content_studio_repository.dart';
import 'create_content_project.dart';

class UpdateContentProject {
  UpdateContentProject(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<ContentProject>> call(ContentProject project) async {
    final Failure? error = CreateContentProject.validate(project);
    if (error != null) return Result.err(error);
    return _repository.updateProject(project.copyWith(updatedAt: DateTime.now()));
  }
}
