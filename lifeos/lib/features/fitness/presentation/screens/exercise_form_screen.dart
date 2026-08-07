import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/equipment_type.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/muscle_group.dart';
import '../providers/exercise_form_controller.dart';
import '../providers/exercise_providers.dart';

final Uuid _uuid = Uuid();

class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({super.key, this.exerciseId});

  final String? exerciseId;

  bool get isEditing => exerciseId != null;

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  MuscleGroup _muscleGroup = MuscleGroup.chest;
  EquipmentType _equipment = EquipmentType.barbell;
  Exercise? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _prefillFrom(Exercise exercise) {
    _original = exercise;
    _nameController.text = exercise.name;
    _instructionsController.text = exercise.instructions ?? '';
    _muscleGroup = exercise.muscleGroup;
    _equipment = exercise.equipment;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Exercise exercise = Exercise(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      muscleGroup: _muscleGroup,
      equipment: _equipment,
      instructions:
          _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
      isCustom: _original?.isCustom ?? true,
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(exerciseFormControllerProvider.notifier)
        .save(exercise, isEditing: widget.isEditing);

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
      title: 'Delete exercise?',
      message: 'This removes it from the library. Any logged sets referencing it stay in your history.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteExerciseUseCaseProvider).call(id);
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
      final AsyncValue<Exercise?> exerciseAsync = ref.watch(exerciseByIdProvider(widget.exerciseId!));
      return exerciseAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit exercise')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit exercise')),
          body: Center(child: Text('Could not load exercise: $error')),
        ),
        data: (Exercise? exercise) {
          if (exercise == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit exercise')),
              body: const Center(child: Text('Exercise not found.')),
            );
          }
          _prefillFrom(exercise);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(exerciseFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit exercise' : 'New exercise'),
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
              label: 'Exercise name',
              controller: _nameController,
              prefixIcon: Icons.fitness_center_outlined,
              validator: (value) => Validators.required(value, field: 'Exercise name'),
            ),
            const SizedBox(height: 16),
            Text('Muscle group', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MuscleGroup group in MuscleGroup.values)
                  ChoiceChip(
                    label: Text(group.label),
                    selected: group == _muscleGroup,
                    onSelected: (_) => setState(() => _muscleGroup = group),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Equipment', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final EquipmentType type in EquipmentType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _equipment,
                    onSelected: (_) => setState(() => _equipment = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Instructions (optional)',
              controller: _instructionsController,
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
