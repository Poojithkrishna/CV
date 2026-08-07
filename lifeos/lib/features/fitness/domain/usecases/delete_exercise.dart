import '../../../../core/utils/result.dart';
import '../repositories/exercise_repository.dart';

class DeleteExercise {
  DeleteExercise(this._repository);

  final ExerciseRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteExercise(id);
}
