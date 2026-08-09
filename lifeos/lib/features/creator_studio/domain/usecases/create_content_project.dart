import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/content_project.dart';
import '../repositories/content_studio_repository.dart';

class CreateContentProject {
  CreateContentProject(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<ContentProject>> call(ContentProject project) async {
    final Failure? error = validate(project);
    if (error != null) return Result.err(error);
    return _repository.createProject(project);
  }

  static Failure? validate(ContentProject project) {
    if (project.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    return null;
  }
}
