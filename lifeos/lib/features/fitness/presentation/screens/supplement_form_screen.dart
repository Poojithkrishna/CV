import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/supplement.dart';
import '../providers/supplement_form_controller.dart';
import '../providers/supplement_providers.dart';

final Uuid _uuid = Uuid();

class SupplementFormScreen extends ConsumerStatefulWidget {
  const SupplementFormScreen({super.key, this.supplementId});

  final String? supplementId;

  bool get isEditing => supplementId != null;

  @override
  ConsumerState<SupplementFormScreen> createState() => _SupplementFormScreenState();
}

class _SupplementFormScreenState extends ConsumerState<SupplementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  int _colorValue = AppGradients.palette.first.colors.first.value;
  Supplement? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Supplement supplement) {
    _original = supplement;
    _nameController.text = supplement.name;
    _dosageController.text = supplement.dosageLabel;
    _notesController.text = supplement.notes ?? '';
    _colorValue = supplement.colorValue;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Supplement supplement = Supplement(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      dosageLabel: _dosageController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      colorValue: _colorValue,
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(supplementFormControllerProvider.notifier)
        .save(supplement, isEditing: widget.isEditing);

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
      title: 'Delete supplement?',
      message: 'This permanently removes it and its intake history.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteSupplementUseCaseProvider).call(id);
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
      final AsyncValue<Supplement?> supplementAsync =
          ref.watch(supplementByIdProvider(widget.supplementId!));
      return supplementAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit supplement')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit supplement')),
          body: Center(child: Text('Could not load supplement: $error')),
        ),
        data: (Supplement? supplement) {
          if (supplement == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit supplement')),
              body: const Center(child: Text('Supplement not found.')),
            );
          }
          _prefillFrom(supplement);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(supplementFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit supplement' : 'New supplement'),
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
              prefixIcon: Icons.medication_outlined,
              hint: 'e.g. Vitamin D3',
              validator: (value) => Validators.required(value, field: 'Name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Dosage (optional)',
              controller: _dosageController,
              hint: 'e.g. 1000mg, 2 capsules',
            ),
            const SizedBox(height: 16),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create supplement'),
            ),
          ],
        ),
      ),
    );
  }
}
