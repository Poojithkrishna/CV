import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../app/theme/app_gradients.dart';
import '../../domain/entities/calendar_task.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/calendar_providers.dart';
import '../providers/task_form_controller.dart';

final Uuid _uuid = Uuid();

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _dueDate;
  bool _isTimeBlocked = false;
  TaskPriority _priority = TaskPriority.medium;
  bool _isDone = false;
  bool _reminderEnabled = false;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  CalendarTask? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(CalendarTask task) {
    _original = task;
    _titleController.text = task.title;
    _notesController.text = task.notes ?? '';
    _dueDate = task.dueDate;
    _isTimeBlocked = task.isTimeBlocked;
    _priority = task.priority;
    _isDone = task.isDone;
    _reminderEnabled = task.reminderEnabled;
    _colorValue = task.colorValue;
    _prefilled = true;
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dueDate = _isTimeBlocked && _dueDate != null
          ? DateTime(picked.year, picked.month, picked.day, _dueDate!.hour, _dueDate!.minute)
          : picked;
    });
  }

  Future<void> _pickTimeBlock() async {
    final DateTime base = _dueDate ?? DateTime.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null) return;
    setState(() {
      _dueDate = DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
      _isTimeBlocked = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final CalendarTask task = CalendarTask(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      dueDate: _dueDate,
      isTimeBlocked: _isTimeBlocked && _dueDate != null,
      priority: _priority,
      isDone: _isDone,
      reminderEnabled: _reminderEnabled,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(taskFormControllerProvider.notifier)
        .save(task, isEditing: widget.isEditing);

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
      title: 'Delete this task?',
      message: 'This permanently removes it.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteTaskUseCaseProvider).call(id);
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
      final AsyncValue<CalendarTask?> taskAsync = ref.watch(taskByIdProvider(widget.taskId!));
      return taskAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit task')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit task')),
          body: Center(child: Text('Could not load task: $error')),
        ),
        data: (CalendarTask? task) {
          if (task == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit task')),
              body: const Center(child: Text('Task not found.')),
            );
          }
          _prefillFrom(task);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(taskFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit task' : 'New task'),
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
              label: 'Title',
              controller: _titleController,
              prefixIcon: Icons.check_box_outlined,
              validator: (value) => Validators.required(value, field: 'Title'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_dueDate == null ? 'No due date' : AppFormatters.relativeDay(_dueDate!)),
              trailing: _dueDate == null
                  ? const Icon(Icons.edit_outlined, size: 18)
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() {
                        _dueDate = null;
                        _isTimeBlocked = false;
                      }),
                    ),
              onTap: _pickDueDate,
            ),
            if (_dueDate != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time block'),
                subtitle: Text(_isTimeBlocked ? AppFormatters.time(_dueDate!) : 'Not scheduled to an hour'),
                value: _isTimeBlocked,
                onChanged: (value) {
                  if (value) {
                    _pickTimeBlock();
                  } else {
                    setState(() => _isTimeBlocked = false);
                  }
                },
              ),
            const SizedBox(height: 8),
            Text('Priority', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final TaskPriority priority in TaskPriority.values)
                  ChoiceChip(
                    avatar: Icon(priority.icon, size: 16, color: priority.color),
                    label: Text(priority.label),
                    selected: priority == _priority,
                    onSelected: (_) => setState(() => _priority = priority),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder'),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (widget.isEditing)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Done'),
                value: _isDone,
                onChanged: (value) => setState(() => _isDone = value),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Add task'),
            ),
          ],
        ),
      ),
    );
  }
}
