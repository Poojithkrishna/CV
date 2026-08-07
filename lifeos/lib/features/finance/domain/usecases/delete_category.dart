import '../../../../core/utils/result.dart';
import '../repositories/category_repository.dart';

/// Deleting a category never destroys transaction history: the
/// `categoryId` foreign key is `ON DELETE SET NULL`, so past transactions
/// simply become "uncategorized" instead of being blocked or cascaded.
class DeleteCategory {
  DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteCategory(id);
}
