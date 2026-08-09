import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/cardio_session.dart';
import '../../domain/entities/cardio_type.dart';
import '../providers/cardio_form_controller.dart';
import '../providers/cardio_providers.dart';

final Uuid _uuid = Uuid();

class CardioFormScreen extends ConsumerStatefulWidget {
  const CardioFormScreen({super.key, this.sessionId});

  final String? sessionId;

  bool get isEditing => sessionId != null;

  @override
  ConsumerState<CardioFormScreen> createState() => _CardioFormScreenState();
}

class _CardioFormScreenState extends ConsumerState<CardioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  CardioType _type = CardioType.running;
  DateTime _date = DateTime.now();
  CardioSession? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(CardioSession session) {
    _original = session;
    _type = session.type;
    _date = session.date;
    _durationController.text = session.durationMinutes.toStringAsFixed(0);
    _distanceController.text = session.distanceKm?.toStringAsFixed(1) ?? '';
    _caloriesController.text = session.caloriesBurned?.toStringAsFixed(0) ?? '';
    _notesController.text = session.notes ?? '';
    _prefilled = true;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final CardioSession session = CardioSession(
      id: _original?.id ?? _uuid.v4(),
      type: _type,
      date: _date,
      durationMinutes: double.tryParse(_durationController.text) ?? 0,
      distanceKm:
          _distanceController.text.trim().isEmpty ? null : double.tryParse(_distanceController.text),
      caloriesBurned:
          _caloriesController.text.trim().isEmpty ? null : double.tryParse(_caloriesController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(cardioFormControllerProvider.notifier)
        .save(session, isEditing: widget.isEditing);

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
      title: 'Delete session?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteCardioSessionUseCaseProvider).call(id);
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
      final AsyncValue<CardioSession?> sessionAsync =
          ref.watch(cardioSessionByIdProvider(widget.sessionId!));
      return sessionAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit session')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit session')),
          body: Center(child: Text('Could not load session: $error')),
        ),
        data: (CardioSession? session) {
          if (session == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit session')),
              body: const Center(child: Text('Session not found.')),
            );
          }
          _prefillFrom(session);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(cardioFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit session' : 'New cardio session'),
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
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final CardioType type in CardioType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(AppFormatters.shortDate(_date)),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Duration (minutes)',
              controller: _durationController,
              prefixIcon: Icons.timer_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) {
                final double? parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a duration greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Distance (km, optional)',
              controller: _distanceController,
              prefixIcon: Icons.straighten_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Distance'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Calories burned (optional)',
              controller: _caloriesController,
              prefixIcon: Icons.local_fire_department_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Calories'),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Log session'),
            ),
          ],
        ),
      ),
    );
  }
}
