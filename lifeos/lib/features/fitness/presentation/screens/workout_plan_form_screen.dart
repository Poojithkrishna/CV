import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../domain/entities/workout_plan.dart';
import '../../domain/entities/workout_plan_type.dart';
import '../providers/workout_plan_form_controller.dart';
import '../providers/workout_plan_providers.dart';

final Uuid _uuid = Uuid();

class WorkoutPlanFormScreen extends ConsumerStatefulWidget {
  const WorkoutPlanFormScreen({super.key, this.planId});

  final String? planId;

  bool get isEditing => planId != null;

  @override
  ConsumerState<WorkoutPlanFormScreen> createState() => _WorkoutPlanFormScreenState();
}

class _WorkoutPlanFormScreenState extends ConsumerState<WorkoutPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  WorkoutPlanType _type = WorkoutPlanType.gym;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  WorkoutPlan? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(WorkoutPlan plan) {
    _original = plan;
    _nameController.text = plan.name;
    _notesController.text = plan.notes ?? '';
    _type = plan.type;
    _colorValue = plan.colorValue;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final WorkoutPlan plan = WorkoutPlan(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isActive: _original?.isActive ?? false,
      isArchived: _original?.isArchived ?? false,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(workoutPlanFormControllerProvider.notifier)
        .save(plan, isEditing: widget.isEditing);

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
      final AsyncValue<WorkoutPlan?> planAsync = ref.watch(workoutPlanByIdProvider(widget.planId!));
      return planAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit plan')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit plan')),
          body: Center(child: Text('Could not load plan: $error')),
        ),
        data: (WorkoutPlan? plan) {
          if (plan == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit plan')),
              body: const Center(child: Text('Plan not found.')),
            );
          }
          _prefillFrom(plan);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(workoutPlanFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit plan' : 'New workout plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Plan name',
              controller: _nameController,
              prefixIcon: Icons.event_note_outlined,
              validator: (value) => Validators.required(value, field: 'Plan name'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final WorkoutPlanType type in WorkoutPlanType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create plan'),
            ),
          ],
        ),
      ),
    );
  }
}
