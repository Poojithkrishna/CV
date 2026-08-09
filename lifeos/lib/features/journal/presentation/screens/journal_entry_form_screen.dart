import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_entry_type.dart';
import '../../domain/entities/mood.dart';
import '../providers/journal_entry_form_controller.dart';
import '../providers/journal_providers.dart';

final Uuid _uuid = Uuid();

class JournalEntryFormScreen extends ConsumerStatefulWidget {
  const JournalEntryFormScreen({super.key, this.entryId, this.initialType});

  final String? entryId;
  final JournalEntryType? initialType;

  bool get isEditing => entryId != null;

  @override
  ConsumerState<JournalEntryFormScreen> createState() => _JournalEntryFormScreenState();
}

class _JournalEntryFormScreenState extends ConsumerState<JournalEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  late JournalEntryType _type = widget.initialType ?? JournalEntryType.freeWriting;
  DateTime _date = DateTime.now();
  Mood? _mood;
  JournalEntry? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _prefillFrom(JournalEntry entry) {
    _original = entry;
    _contentController.text = entry.content;
    _type = entry.type;
    _date = entry.date;
    _mood = entry.mood;
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
    final JournalEntry entry = JournalEntry(
      id: _original?.id ?? _uuid.v4(),
      type: _type,
      date: _date,
      content: _contentController.text.trim(),
      mood: _mood,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(journalEntryFormControllerProvider.notifier)
        .save(entry, isEditing: widget.isEditing);

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
      title: 'Delete this entry?',
      message: 'This permanently removes it from your journal.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteJournalEntryUseCaseProvider).call(id);
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
      final AsyncValue<JournalEntry?> entryAsync = ref.watch(journalEntryByIdProvider(widget.entryId!));
      return entryAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit entry')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit entry')),
          body: Center(child: Text('Could not load entry: $error')),
        ),
        data: (JournalEntry? entry) {
          if (entry == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit entry')),
              body: const Center(child: Text('Entry not found.')),
            );
          }
          _prefillFrom(entry);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(journalEntryFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit entry' : 'New entry'),
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
                for (final JournalEntryType type in JournalEntryType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16, color: type.color),
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
            Text('Mood (optional)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final Mood mood in Mood.values)
                  ChoiceChip(
                    avatar: Icon(mood.icon, size: 16),
                    label: Text(mood.label),
                    selected: mood == _mood,
                    onSelected: (_) => setState(() => _mood = _mood == mood ? null : mood),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'What\'s on your mind?',
              controller: _contentController,
              maxLines: 12,
              validator: (value) => Validators.required(value, field: 'Content'),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Save entry'),
            ),
          ],
        ),
      ),
    );
  }
}
