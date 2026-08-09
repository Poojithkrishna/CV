import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../providers/event_form_controller.dart';

final Uuid _uuid = Uuid();

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.eventId});

  final String? eventId;

  bool get isEditing => eventId != null;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startTime = _roundToNextHour(DateTime.now());
  DateTime? _endTime;
  bool _isAllDay = false;
  bool _reminderEnabled = false;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  CalendarEvent? _original;
  bool _prefilled = false;

  static DateTime _roundToNextHour(DateTime dt) {
    final DateTime truncated = DateTime(dt.year, dt.month, dt.day, dt.hour);
    return truncated.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(CalendarEvent event) {
    _original = event;
    _titleController.text = event.title;
    _locationController.text = event.location ?? '';
    _notesController.text = event.notes ?? '';
    _startTime = event.startTime;
    _endTime = event.endTime;
    _isAllDay = event.isAllDay;
    _reminderEnabled = event.reminderEnabled;
    _colorValue = event.colorValue;
    _prefilled = true;
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    if (_isAllDay) return DateTime(date.year, date.month, date.day);
    if (!mounted) return null;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return DateTime(date.year, date.month, date.day, initial.hour, initial.minute);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStart() async {
    final DateTime? picked = await _pickDateTime(_startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEnd() async {
    final DateTime? picked = await _pickDateTime(_endTime ?? _startTime.add(const Duration(hours: 1)));
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final CalendarEvent event = CalendarEvent(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      isAllDay: _isAllDay,
      reminderEnabled: _reminderEnabled,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(eventFormControllerProvider.notifier)
        .save(event, isEditing: widget.isEditing);

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
      title: 'Delete this event?',
      message: 'This permanently removes it.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteEventUseCaseProvider).call(id);
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
      final AsyncValue<CalendarEvent?> eventAsync = ref.watch(eventByIdProvider(widget.eventId!));
      return eventAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit event')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit event')),
          body: Center(child: Text('Could not load event: $error')),
        ),
        data: (CalendarEvent? event) {
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit event')),
              body: const Center(child: Text('Event not found.')),
            );
          }
          _prefillFrom(event);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(eventFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit event' : 'New event'),
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
              prefixIcon: Icons.event_outlined,
              validator: (value) => Validators.required(value, field: 'Title'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All day'),
              value: _isAllDay,
              onChanged: (value) => setState(() => _isAllDay = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.play_arrow_outlined),
              title: Text(
                _isAllDay
                    ? 'Starts ${AppFormatters.shortDate(_startTime)}'
                    : 'Starts ${AppFormatters.shortDate(_startTime)} · ${AppFormatters.time(_startTime)}',
              ),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickStart,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.stop_outlined),
              title: Text(
                _endTime == null
                    ? 'No end time'
                    : _isAllDay
                        ? 'Ends ${AppFormatters.shortDate(_endTime!)}'
                        : 'Ends ${AppFormatters.shortDate(_endTime!)} · ${AppFormatters.time(_endTime!)}',
              ),
              trailing: _endTime == null
                  ? const Icon(Icons.edit_outlined, size: 18)
                  : IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _endTime = null),
                    ),
              onTap: _pickEnd,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Location (optional)',
              controller: _locationController,
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder'),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Add event'),
            ),
          ],
        ),
      ),
    );
  }
}
