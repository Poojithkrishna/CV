import '../../../../core/utils/result.dart';
import '../repositories/media_library_repository.dart';

class LogMediaProgress {
  LogMediaProgress(this._repository);

  final MediaLibraryRepository _repository;

  Future<Result<void>> call(String id, int delta) => _repository.adjustProgress(id, delta);
}
