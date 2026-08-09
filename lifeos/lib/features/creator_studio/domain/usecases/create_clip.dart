import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/clip.dart';
import '../repositories/content_studio_repository.dart';

class CreateClip {
  CreateClip(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<Clip>> call(Clip clip) async {
    final Failure? error = validate(clip);
    if (error != null) return Result.err(error);
    return _repository.createClip(clip);
  }

  static Failure? validate(Clip clip) {
    if (clip.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    return null;
  }
}
