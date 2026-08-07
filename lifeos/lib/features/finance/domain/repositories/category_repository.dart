import '../../../../core/utils/result.dart';
import '../entities/category.dart';
import '../entities/category_type.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchCategories({CategoryType? type});
  Stream<Category?> watchCategory(String id);

  Future<Result<Category>> createCategory(Category category);
  Future<Result<Category>> updateCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
}
