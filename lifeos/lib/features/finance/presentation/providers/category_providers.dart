import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/categories_dao.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';

final Provider<CategoriesDao> categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return CategoriesDao(ref.watch(appDatabaseProvider));
});

final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoriesDaoProvider));
});

final Provider<CreateCategory> createCategoryUseCaseProvider = Provider(
  (ref) => CreateCategory(ref.watch(categoryRepositoryProvider)),
);

final Provider<UpdateCategory> updateCategoryUseCaseProvider = Provider(
  (ref) => UpdateCategory(ref.watch(categoryRepositoryProvider)),
);

final Provider<DeleteCategory> deleteCategoryUseCaseProvider = Provider(
  (ref) => DeleteCategory(ref.watch(categoryRepositoryProvider)),
);

/// All active categories, both types — used by the categories management
/// screen.
final StreamProvider<List<Category>> allCategoriesProvider =
    StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchCategories();
});

/// Categories filtered to one type — used by the transaction form's
/// category picker.
final StreamProviderFamily<List<Category>, CategoryType> categoriesByTypeProvider =
    StreamProvider.family<List<Category>, CategoryType>((ref, type) {
  return ref.watch(categoryRepositoryProvider).watchCategories(type: type);
});

final StreamProviderFamily<Category?, String> categoryByIdProvider =
    StreamProvider.family<Category?, String>((ref, id) {
  return ref.watch(categoryRepositoryProvider).watchCategory(id);
});
