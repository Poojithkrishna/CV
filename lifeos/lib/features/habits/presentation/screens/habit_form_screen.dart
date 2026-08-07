import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';
import '../providers/habit_form_controller.dart';
import '../providers/habit_providers.dart';

final Uuid _uuid = Uuid();

const List<String> _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  bool get isEditing => habitId != null;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();
  final List<TextEditingController> _checklistControllers = [];

  HabitType _type = HabitType.yesNo;
  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _customWeekdays = {};
  int _colorValue = AppGradients.palette.first.colors.first.value;
  Habit? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _notesController.dispose();
    for (final controller in _checklistControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _prefillFrom(Habit habit) {
    _original = habit;
    _nameController.text = habit.name;
    _targetController.text = habit.targetValue.toStringAsFixed(
      habit.targetValue.truncateToDouble() == habit.targetValue ? 0 : 1,
    );
    _unitController.text = habit.unit ?? '';
    _notesController.text = habit.notes ?? '';
    _type = habit.type;
    _frequency = habit.frequency;
    _customWeekdays.addAll(habit.customWeekdays);
    _colorValue = habit.colorValue;
    for (final item in habit.checklistItems) {
      _checklistControllers.add(TextEditingController(text: item));
    }
    _prefilled = true;
  }

  void _addChecklistRow() {
    setState(() => _checklistControllers.add(TextEditingController()));
  }

  void _removeChecklistRow(int index) {
    setState(() => _checklistControllers.removeAt(index).dispose());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final List<String> checklistItems = _checklistControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final Habit habit = Habit(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      frequency: _frequency,
      targetValue: double.tryParse(_targetController.text) ?? 1,
      unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      customWeekdays: _frequency == HabitFrequency.custom ? Set.of(_customWeekdays) : const {},
      checklistItems: _type.usesChecklistItems ? checklistItems : const [],
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(habitFormControllerProvider.notifier)
        .save(habit, isEditing: widget.isEditing);

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
      final AsyncValue<Habit?> habitAsync = ref.watch(habitByIdProvider(widget.habitId!));
      return habitAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit habit')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit habit')),
          body: Center(child: Text('Could not load habit: $error')),
        ),
        data: (Habit? habit) {
          if (habit == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit habit')),
              body: const Center(child: Text('Habit not found.')),
            );
          }
          _prefillFrom(habit);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(habitFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit habit' : 'New habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Habit name',
              controller: _nameController,
              prefixIcon: Icons.local_fire_department_outlined,
              validator: (value) => Validators.required(value, field: 'Habit name'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final HabitType type in HabitType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Repeats', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final HabitFrequency frequency in HabitFrequency.values)
                  ChoiceChip(
                    label: Text(frequency.label),
                    selected: frequency == _frequency,
                    onSelected: (_) => setState(() => _frequency = frequency),
                  ),
              ],
            ),
            if (_frequency == HabitFrequency.custom) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  for (int day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(_weekdayLabels[day - 1]),
                      selected: _customWeekdays.contains(day),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _customWeekdays.add(day);
                        } else {
                          _customWeekdays.remove(day);
                        }
                      }),
                    ),
                ],
              ),
            ],
            if (_type.usesNumericTarget) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Target',
                      controller: _targetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimalInputFormatters,
                      validator: (value) {
                        final double? parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) return 'Enter a target greater than zero';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Unit (optional)',
                      controller: _unitController,
                      hint: 'glasses, minutes, pages…',
                    ),
                  ),
                ],
              ),
            ],
            if (_type.usesChecklistItems) ...[
              const SizedBox(height: 16),
              Text('Checklist items', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              for (int i = 0; i < _checklistControllers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Item ${i + 1}',
                          controller: _checklistControllers[i],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeChecklistRow(i),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: _addChecklistRow,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add item'),
              ),
            ],
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create habit'),
            ),
          ],
        ),
      ),
    );
  }
}
