import '../../../../core/utils/result.dart';
import '../repositories/habit_repository.dart';

class DeleteHabit {
  DeleteHabit(this._repository);

  final HabitRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteHabit(id);
}
