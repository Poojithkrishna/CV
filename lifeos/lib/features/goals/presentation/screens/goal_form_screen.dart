import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_form_controller.dart';
import '../providers/goal_providers.dart';

final Uuid _uuid = Uuid();

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.goalId});

  final String? goalId;

  bool get isEditing => goalId != null;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');

  DateTime? _targetDate;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  Goal? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _prefillFrom(Goal goal) {
    _original = goal;
    _titleController.text = goal.title;
    _descriptionController.text = goal.description ?? '';
    _targetController.text = goal.targetValue.toStringAsFixed(
      goal.targetValue.truncateToDouble() == goal.targetValue ? 0 : 1,
    );
    _targetDate = goal.targetDate;
    _colorValue = goal.colorValue;
    _prefilled = true;
  }

  Future<void> _pickTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Goal goal = Goal(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      targetDate: _targetDate,
      progressValue: _original?.progressValue ?? 0,
      targetValue: double.tryParse(_targetController.text) ?? 1,
      colorValue: _colorValue,
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(goalFormControllerProvider.notifier)
        .save(goal, isEditing: widget.isEditing);

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
      final AsyncValue<Goal?> goalAsync = ref.watch(goalByIdProvider(widget.goalId!));
      return goalAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit goal')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit goal')),
          body: Center(child: Text('Could not load goal: $error')),
        ),
        data: (Goal? goal) {
          if (goal == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit goal')),
              body: const Center(child: Text('Goal not found.')),
            );
          }
          _prefillFrom(goal);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(goalFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit goal' : 'New goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Goal title',
              controller: _titleController,
              prefixIcon: Icons.flag_outlined,
              validator: (value) => Validators.required(value, field: 'Goal title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description (optional)',
              controller: _descriptionController,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_targetDate != null
                  ? 'Target date ${AppFormatters.shortDate(_targetDate!)}'
                  : 'No target date'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickTargetDate,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Target (used if you don\'t add milestones)',
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) {
                final double? parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a target greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ColorThemePicker(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create goal'),
            ),
          ],
        ),
      ),
    );
  }
}
