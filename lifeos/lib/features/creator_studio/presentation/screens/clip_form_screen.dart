import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/photo_storage.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/clip.dart';
import '../../domain/entities/content_project.dart';
import '../providers/clip_form_controller.dart';
import '../providers/content_studio_providers.dart';

final Uuid _uuid = Uuid();

class ClipFormScreen extends ConsumerStatefulWidget {
  const ClipFormScreen({super.key, this.clipId});

  final String? clipId;

  bool get isEditing => clipId != null;

  @override
  ConsumerState<ClipFormScreen> createState() => _ClipFormScreenState();
}

class _ClipFormScreenState extends ConsumerState<ClipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _gameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _capturedAt = DateTime.now();
  String? _thumbnailPath;
  String? _linkedProjectId;
  Clip? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _gameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Clip clip) {
    _original = clip;
    _titleController.text = clip.title;
    _gameController.text = clip.game;
    _notesController.text = clip.notes ?? '';
    _capturedAt = clip.capturedAt;
    _thumbnailPath = clip.thumbnailPath;
    _linkedProjectId = clip.linkedProjectId;
    _prefilled = true;
  }

  Future<ImageSource?> _pickSource(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    final ImageSource? source = await _pickSource(context);
    if (source == null) return;
    final XFile? picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final String savedPath = await saveImageFile(
      picked.path,
      _original?.id ?? _uuid.v4(),
      subdirectory: 'clip_thumbnails',
    );
    setState(() => _thumbnailPath = savedPath);
  }

  Future<void> _pickCapturedAt() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _capturedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _capturedAt = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Clip clip = Clip(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      game: _gameController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      thumbnailPath: _thumbnailPath,
      linkedProjectId: _linkedProjectId,
      capturedAt: _capturedAt,
      createdAt: _original?.createdAt ?? now,
    );

    final result = await ref
        .read(clipFormControllerProvider.notifier)
        .save(clip, isEditing: widget.isEditing);

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
      title: 'Delete clip?',
      message: 'This permanently removes it from your library.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteClipUseCaseProvider).call(id);
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
      final AsyncValue<Clip?> clipAsync = ref.watch(clipByIdProvider(widget.clipId!));
      return clipAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit clip')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit clip')),
          body: Center(child: Text('Could not load clip: $error')),
        ),
        data: (Clip? clip) {
          if (clip == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit clip')),
              body: const Center(child: Text('Clip not found.')),
            );
          }
          _prefillFrom(clip);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(clipFormControllerProvider);
    final bool isSaving = formState.isLoading;
    final List<ContentProject> projects = ref.watch(allContentProjectsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit clip' : 'New clip'),
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
            GestureDetector(
              onTap: _pickThumbnail,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _thumbnailPath == null
                      ? Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(Icons.add_photo_alternate_outlined, size: 32),
                          ),
                        )
                      : Image.file(File(_thumbnailPath!), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Title',
              controller: _titleController,
              prefixIcon: Icons.movie_creation_outlined,
              validator: (value) => Validators.required(value, field: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Game (optional)',
              controller: _gameController,
              prefixIcon: Icons.sports_esports_outlined,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text('Captured ${AppFormatters.shortDate(_capturedAt)}'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickCapturedAt,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: projects.any((p) => p.id == _linkedProjectId) ? _linkedProjectId : null,
              decoration: const InputDecoration(
                labelText: 'Linked project (optional)',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('None')),
                for (final ContentProject project in projects)
                  DropdownMenuItem<String?>(value: project.id, child: Text(project.title)),
              ],
              onChanged: (value) => setState(() => _linkedProjectId = value),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Save clip'),
            ),
          ],
        ),
      ),
    );
  }
}
