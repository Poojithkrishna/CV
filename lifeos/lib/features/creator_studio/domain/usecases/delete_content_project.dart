import '../../../../core/utils/result.dart';
import '../repositories/content_studio_repository.dart';

class DeleteContentProject {
  DeleteContentProject(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteProject(id);
}
