import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call(Category category) async {
    if (category.name.trim().isEmpty) {
      return const Result.err(ValidationFailure('Category name is required.'));
    }
    return _repository.createCategory(category);
  }
}
