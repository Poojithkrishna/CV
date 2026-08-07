import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_type.dart';
import '../providers/category_form_controller.dart';
import '../providers/category_providers.dart';
import '../widgets/category_icon_picker.dart';
import '../widgets/color_theme_picker.dart';

final Uuid _uuid = Uuid();

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.categoryId});

  final String? categoryId;

  bool get isEditing => categoryId != null;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CategoryType _type = CategoryType.expense;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  String? _iconKey;
  Category? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _prefillFrom(Category category) {
    _original = category;
    _nameController.text = category.name;
    _type = category.type;
    _colorValue = category.colorValue;
    _iconKey = category.iconKey;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Category category = Category(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      colorValue: _colorValue,
      iconKey: _iconKey,
      isArchived: _original?.isArchived ?? false,
      sortOrder: _original?.sortOrder ?? 0,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(categoryFormControllerProvider.notifier)
        .save(category, isEditing: widget.isEditing);

    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_prefilled) {
      final AsyncValue<Category?> categoryAsync =
          ref.watch(categoryByIdProvider(widget.categoryId!));
      return categoryAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit category')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit category')),
          body: Center(child: Text('Could not load category: $error')),
        ),
        data: (Category? category) {
          if (category == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit category')),
              body: const Center(child: Text('Category not found.')),
            );
          }
          _prefillFrom(category);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(categoryFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit category' : 'New category')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Category name',
              controller: _nameController,
              prefixIcon: Icons.label_outline_rounded,
              validator: (value) => Validators.required(value, field: 'Category name'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final CategoryType type in CategoryType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ColorThemePicker(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 20),
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            CategoryIconPicker(
              selectedKey: _iconKey,
              color: Color(_colorValue),
              onChanged: (key) => setState(() => _iconKey = key),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Save changes' : 'Create category'),
            ),
          ],
        ),
      ),
    );
  }
}
