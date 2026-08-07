import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/category.dart';
import 'package:lifeos/features/finance/domain/entities/category_type.dart';
import 'package:lifeos/features/finance/domain/repositories/category_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_category.dart';

class _FakeCategoryRepository implements CategoryRepository {
  Category? saved;

  @override
  Future<Result<Category>> createCategory(Category category) async {
    saved = category;
    return Result.ok(category);
  }

  @override
  Future<Result<void>> deleteCategory(String id) async => const Result.ok(null);

  @override
  Future<Result<Category>> updateCategory(Category category) async => Result.ok(category);

  @override
  Stream<Category?> watchCategory(String id) => const Stream.empty();

  @override
  Stream<List<Category>> watchCategories({CategoryType? type}) => const Stream.empty();
}

Category _buildCategory({String name = 'Food'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Category(
    id: 'cat-1',
    name: name,
    type: CategoryType.expense,
    colorValue: 0xFFF59E0B,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateCategory', () {
    test('persists a valid category', () async {
      final repo = _FakeCategoryRepository();
      final useCase = CreateCategory(repo);

      final result = await useCase(_buildCategory());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Food');
    });

    test('rejects a blank name', () async {
      final repo = _FakeCategoryRepository();
      final useCase = CreateCategory(repo);

      final result = await useCase(_buildCategory(name: '   '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
