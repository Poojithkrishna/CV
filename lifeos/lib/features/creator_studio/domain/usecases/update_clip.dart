import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/clip.dart';
import '../repositories/content_studio_repository.dart';
import 'create_clip.dart';

class UpdateClip {
  UpdateClip(this._repository);

  final ContentStudioRepository _repository;

  Future<Result<Clip>> call(Clip clip) async {
    final Failure? error = CreateClip.validate(clip);
    if (error != null) return Result.err(error);
    return _repository.updateClip(clip);
  }
}
