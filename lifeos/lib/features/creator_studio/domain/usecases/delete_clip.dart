import '../../../../core/utils/result.dart';
import '../repositories/content_studio_repository.dart';

class DeleteClip {
  DeleteClip(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteClip(id);
}
