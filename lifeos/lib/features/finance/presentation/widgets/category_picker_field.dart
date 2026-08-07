import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';
import '../providers/category_providers.dart';
import 'category_icons.dart';

/// Dropdown over the categories matching [type], used in the transaction
/// form. Hidden entirely for transfers, which don't carry a category.
class CategoryPickerField extends ConsumerWidget {
  const CategoryPickerField({
    super.key,
    required this.type,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  final CategoryType type;
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categoriesAsync =
        ref.watch(categoriesByTypeProvider(type));

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Could not load categories: $error'),
      data: (List<Category> categories) {
        final bool hasSelected = categories.any((c) => c.id == selectedCategoryId);
        return DropdownButtonFormField<String>(
          value: hasSelected ? selectedCategoryId : null,
          decoration: const InputDecoration(
            labelText: 'Category (optional)',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: [
            for (final Category category in categories)
              DropdownMenuItem(
                value: category.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CategoryIcons.resolve(category.iconKey),
                        size: 18, color: Color(category.colorValue)),
                    const SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}
