import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../providers/asset_form_controller.dart';
import '../providers/asset_providers.dart';

final Uuid _uuid = Uuid();

class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key, this.assetId});

  final String? assetId;

  bool get isEditing => assetId != null;

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentValueController = TextEditingController(text: '0');
  final _purchasePriceController = TextEditingController();
  final _notesController = TextEditingController();

  AssetType _type = AssetType.realEstate;
  DateTime? _purchaseDate;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  Asset? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _currentValueController.dispose();
    _purchasePriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Asset asset) {
    _original = asset;
    _nameController.text = asset.name;
    _currentValueController.text = asset.currentValue.toStringAsFixed(2);
    _purchasePriceController.text = asset.purchasePrice?.toStringAsFixed(2) ?? '';
    _notesController.text = asset.notes ?? '';
    _type = asset.type;
    _purchaseDate = asset.purchaseDate;
    _colorValue = asset.colorValue;
    _prefilled = true;
  }

  Future<void> _pickPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Asset asset = Asset(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      currentValue: double.tryParse(_currentValueController.text) ?? 0,
      purchasePrice: _purchasePriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_purchasePriceController.text),
      purchaseDate: _purchaseDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      colorValue: _colorValue,
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(assetFormControllerProvider.notifier)
        .save(asset, isEditing: widget.isEditing);

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
      title: 'Delete asset?',
      message: 'This permanently removes it from your net worth.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteAssetUseCaseProvider).call(id);
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
      final AsyncValue<Asset?> assetAsync = ref.watch(assetByIdProvider(widget.assetId!));
      return assetAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit asset')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit asset')),
          body: Center(child: Text('Could not load asset: $error')),
        ),
        data: (Asset? asset) {
          if (asset == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit asset')),
              body: const Center(child: Text('Asset not found.')),
            );
          }
          _prefillFrom(asset);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(assetFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit asset' : 'New asset'),
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
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.inventory_2_outlined,
              hint: 'e.g. Downtown Apartment',
              validator: (value) => Validators.required(value, field: 'Name'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final AssetType type in AssetType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Current value',
              controller: _currentValueController,
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Current value'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Purchase price (optional)',
              controller: _purchasePriceController,
              prefixIcon: Icons.receipt_long_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Purchase price'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_purchaseDate != null
                  ? 'Purchased ${AppFormatters.shortDate(_purchaseDate!)}'
                  : 'No purchase date'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickPurchaseDate,
            ),
            const SizedBox(height: 8),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ColorThemePicker(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes (optional)',
              controller: _notesController,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create asset'),
            ),
          ],
        ),
      ),
    );
  }
}
