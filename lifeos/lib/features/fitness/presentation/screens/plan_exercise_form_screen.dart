import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/plan_exercise.dart';
import '../providers/workout_plan_providers.dart';
import '../widgets/exercise_picker_field.dart';

final Uuid _uuid = Uuid();

/// Add/edit an exercise entry within a workout day. [planExercise] is
/// passed in directly (already loaded by the caller) when editing, since
/// the day detail screen already has it in hand from its own stream —
/// no need for a second by-id lookup here.
class PlanExerciseFormScreen extends ConsumerStatefulWidget {
  const PlanExerciseFormScreen({super.key, required this.dayId, this.planExercise});

  final String dayId;
  final PlanExercise? planExercise;

  bool get isEditing => planExercise != null;

  @override
  ConsumerState<PlanExerciseFormScreen> createState() => _PlanExerciseFormScreenState();
}

class _PlanExerciseFormScreenState extends ConsumerState<PlanExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '8-12');
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '90');
  final _notesController = TextEditingController();

  String? _exerciseId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final PlanExercise? existing = widget.planExercise;
    if (existing != null) {
      _exerciseId = existing.exerciseId;
      _setsController.text = existing.targetSets.toString();
      _repsController.text = existing.targetReps;
      _weightController.text = existing.targetWeight?.toString() ?? '';
      _restController.text = existing.restSeconds?.toString() ?? '';
      _notesController.text = existing.notes ?? '';
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exerciseId == null) return;

    setState(() => _isSaving = true);
    final DateTime now = DateTime.now();
    final PlanExercise entry = PlanExercise(
      id: widget.planExercise?.id ?? _uuid.v4(),
      dayId: widget.dayId,
      exerciseId: _exerciseId!,
      targetSets: int.tryParse(_setsController.text) ?? 0,
      targetReps: _repsController.text.trim(),
      targetWeight:
          _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text),
      restSeconds: _restController.text.trim().isEmpty ? null : int.tryParse(_restController.text),
      sortOrder: widget.planExercise?.sortOrder ?? 0,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.planExercise?.createdAt ?? now,
      updatedAt: now,
    );

    final result = widget.isEditing
        ? await ref.read(updatePlanExerciseUseCaseProvider).call(entry)
        : await ref.read(addExerciseToDayUseCaseProvider).call(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit exercise' : 'Add exercise')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            ExercisePickerField(
              selectedExerciseId: _exerciseId,
              onChanged: (value) => setState(() => _exerciseId = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Sets',
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final int? parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Target reps',
                    controller: _repsController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Target weight kg (optional)',
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Rest seconds',
                    controller: _restController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes (optional)',
              controller: _notesController,
              prefixIcon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Save changes' : 'Add to day'),
            ),
          ],
        ),
      ),
    );
  }
}
