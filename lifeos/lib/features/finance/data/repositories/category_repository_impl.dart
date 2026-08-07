import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../daos/categories_dao.dart';
import 'category_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao);

  final CategoriesDao _dao;

  @override
  Stream<List<Category>> watchCategories({CategoryType? type}) {
    return _dao
        .watchActiveCategories(type: type?.name)
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Category?> watchCategory(String id) {
    return _dao.watchCategory(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Category>> createCategory(Category category) async {
    try {
      await _dao.insertCategory(category.toCompanion());
      return Result.ok(category);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save category: $e'));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    try {
      final bool updated = await _dao.updateCategory(category.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Category no longer exists.'));
      }
      return Result.ok(category);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update category: $e'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _dao.deleteCategory(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete category: $e'));
    }
  }
}
