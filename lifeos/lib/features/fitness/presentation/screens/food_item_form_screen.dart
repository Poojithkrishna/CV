import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/food_item.dart';
import '../providers/food_item_form_controller.dart';
import '../providers/nutrition_providers.dart';

final Uuid _uuid = Uuid();

class FoodItemFormScreen extends ConsumerStatefulWidget {
  const FoodItemFormScreen({super.key, this.foodItemId});

  final String? foodItemId;

  bool get isEditing => foodItemId != null;

  @override
  ConsumerState<FoodItemFormScreen> createState() => _FoodItemFormScreenState();
}

class _FoodItemFormScreenState extends ConsumerState<FoodItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingLabelController = TextEditingController(text: 'serving');
  final _caloriesController = TextEditingController(text: '0');
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');

  FoodItem? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _servingLabelController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _prefillFrom(FoodItem item) {
    _original = item;
    _nameController.text = item.name;
    _servingLabelController.text = item.servingLabel;
    _caloriesController.text = item.caloriesPerServing.toStringAsFixed(0);
    _proteinController.text = item.proteinG.toStringAsFixed(0);
    _carbsController.text = item.carbsG.toStringAsFixed(0);
    _fatController.text = item.fatG.toStringAsFixed(0);
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final FoodItem item = FoodItem(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      caloriesPerServing: double.tryParse(_caloriesController.text) ?? 0,
      proteinG: double.tryParse(_proteinController.text) ?? 0,
      carbsG: double.tryParse(_carbsController.text) ?? 0,
      fatG: double.tryParse(_fatController.text) ?? 0,
      servingLabel:
          _servingLabelController.text.trim().isEmpty ? 'serving' : _servingLabelController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(foodItemFormControllerProvider.notifier)
        .save(item, isEditing: widget.isEditing);

    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _delete() async {
    final String? id = _original?.id;
    if (id == null) return;
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete food?',
      message: 'This removes it from your library. Any logged servings stay in your history.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteFoodItemUseCaseProvider).call(id);
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
      final AsyncValue<FoodItem?> itemAsync = ref.watch(foodItemByIdProvider(widget.foodItemId!));
      return itemAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit food')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit food')),
          body: Center(child: Text('Could not load food: $error')),
        ),
        data: (FoodItem? item) {
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit food')),
              body: const Center(child: Text('Food not found.')),
            );
          }
          _prefillFrom(item);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(foodItemFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit food' : 'New food'),
        actions: [
          if (widget.isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Food name',
              controller: _nameController,
              prefixIcon: Icons.restaurant_outlined,
              validator: (value) => Validators.required(value, field: 'Food name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Serving label',
              controller: _servingLabelController,
              hint: 'e.g. cup, 100 g, 1 slice',
            ),
            const SizedBox(height: 16),
            Text('Per serving', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Calories (kcal)',
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Calories'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Protein (g)',
                    controller: _proteinController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                    validator: (value) => Validators.nonNegativeNumber(value, field: 'Protein'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Carbs (g)',
                    controller: _carbsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                    validator: (value) => Validators.nonNegativeNumber(value, field: 'Carbs'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Fat (g)',
                    controller: _fatController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                    validator: (value) => Validators.nonNegativeNumber(value, field: 'Fat'),
                  ),
                ),
              ],
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create food'),
            ),
          ],
        ),
      ),
    );
  }
}
