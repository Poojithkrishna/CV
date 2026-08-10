import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';
import '../providers/category_providers.dart';
import '../widgets/category_avatar.dart';
import '../../../../app/origin/origin_glyphs.dart';

/// Manage categories screen: two sections (Income / Expense), each
/// editable/deletable. Deleting a category never touches transaction
/// history — see [DeleteCategory].
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Category category) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${category.name}"?',
      message: 'Past transactions in this category become uncategorized; they are not deleted.',
    );
    if (!confirmed) return;

    final result = await ref.read(deleteCategoryUseCaseProvider).call(category.id);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/finance/categories/new'),
        icon: OriginGlyph(OriginGlyphType.quickAdd, size: 22),
        label: const Text('Category'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        data: (List<Category> categories) {
          if (categories.isEmpty) {
            return EmptyState(
              glyph: OriginGlyphType.wealth,
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message: 'Create categories to organize your income and expenses.',
              actionLabel: 'Add your first category',
              onAction: () => context.push('/finance/categories/new'),
            );
          }

          final List<Category> income =
              categories.where((c) => c.type == CategoryType.income).toList();
          final List<Category> expense =
              categories.where((c) => c.type == CategoryType.expense).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              if (income.isNotEmpty) ...[
                _SectionHeader(title: 'Income', count: income.length),
                for (final Category category in income)
                  _CategoryTile(
                    category: category,
                    onTap: () => context.push('/finance/categories/${category.id}/edit'),
                    onDelete: () => _delete(context, ref, category),
                  ),
                const SizedBox(height: 16),
              ],
              if (expense.isNotEmpty) ...[
                _SectionHeader(title: 'Expense', count: expense.length),
                for (final Category category in expense)
                  _CategoryTile(
                    category: category,
                    onTap: () => context.push('/finance/categories/${category.id}/edit'),
                    onDelete: () => _delete(context, ref, category),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap, required this.onDelete});

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CategoryAvatar(category: category),
        title: Text(category.name),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
