import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/photo_storage.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/content_platform.dart';
import '../../domain/entities/content_project.dart';
import '../../domain/entities/content_stage.dart';
import '../providers/content_project_form_controller.dart';
import '../providers/content_studio_providers.dart';

final Uuid _uuid = Uuid();

class ContentProjectFormScreen extends ConsumerStatefulWidget {
  const ContentProjectFormScreen({super.key, this.projectId});

  final String? projectId;

  bool get isEditing => projectId != null;

  @override
  ConsumerState<ContentProjectFormScreen> createState() => _ContentProjectFormScreenState();
}

class _ContentProjectFormScreenState extends ConsumerState<ContentProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _gameController = TextEditingController();
  final _notesController = TextEditingController();
  final _viewsController = TextEditingController(text: '0');
  final _likesController = TextEditingController(text: '0');
  final _commentsController = TextEditingController(text: '0');

  ContentPlatform _platform = ContentPlatform.youtube;
  ContentStage _stage = ContentStage.idea;
  DateTime? _scheduledDate;
  String? _thumbnailPath;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  ContentProject? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _gameController.dispose();
    _notesController.dispose();
    _viewsController.dispose();
    _likesController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  void _prefillFrom(ContentProject project) {
    _original = project;
    _titleController.text = project.title;
    _gameController.text = project.game;
    _notesController.text = project.notes ?? '';
    _viewsController.text = '${project.viewCount}';
    _likesController.text = '${project.likeCount}';
    _commentsController.text = '${project.commentCount}';
    _platform = project.platform;
    _stage = project.stage;
    _scheduledDate = project.scheduledDate;
    _thumbnailPath = project.thumbnailPath;
    _colorValue = project.colorValue;
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
      subdirectory: 'content_thumbnails',
    );
    setState(() => _thumbnailPath = savedPath);
  }

  Future<void> _pickScheduledDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final ContentProject project = ContentProject(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      game: _gameController.text.trim(),
      platform: _platform,
      stage: _stage,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      thumbnailPath: _thumbnailPath,
      scheduledDate: _scheduledDate,
      publishedDate: _stage == ContentStage.published
          ? (_original?.publishedDate ?? now)
          : _original?.publishedDate,
      viewCount: int.tryParse(_viewsController.text) ?? 0,
      likeCount: int.tryParse(_likesController.text) ?? 0,
      commentCount: int.tryParse(_commentsController.text) ?? 0,
      colorValue: _colorValue,
      sortOrder: _original?.sortOrder ?? 0,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(contentProjectFormControllerProvider.notifier)
        .save(project, isEditing: widget.isEditing);

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
      title: 'Delete project?',
      message: 'This permanently removes it from the pipeline.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteContentProjectUseCaseProvider).call(id);
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
      final AsyncValue<ContentProject?> projectAsync =
          ref.watch(contentProjectByIdProvider(widget.projectId!));
      return projectAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit project')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit project')),
          body: Center(child: Text('Could not load project: $error')),
        ),
        data: (ContentProject? project) {
          if (project == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit project')),
              body: const Center(child: Text('Project not found.')),
            );
          }
          _prefillFrom(project);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(contentProjectFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit project' : 'New idea'),
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
              prefixIcon: Icons.videocam_outlined,
              validator: (value) => Validators.required(value, field: 'Title'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Game (optional)',
              controller: _gameController,
              prefixIcon: Icons.sports_esports_outlined,
            ),
            const SizedBox(height: 16),
            Text('Platform', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ContentPlatform platform in ContentPlatform.values)
                  ChoiceChip(
                    avatar: Icon(platform.icon, size: 16),
                    label: Text(platform.label),
                    selected: platform == _platform,
                    onSelected: (_) => setState(() => _platform = platform),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Stage', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ContentStage stage in ContentStage.values)
                  ChoiceChip(
                    avatar: Icon(stage.icon, size: 16),
                    label: Text(stage.label),
                    selected: stage == _stage,
                    onSelected: (_) => setState(() => _stage = stage),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_scheduledDate != null
                  ? 'Scheduled ${AppFormatters.shortDate(_scheduledDate!)}'
                  : 'No scheduled date'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickScheduledDate,
            ),
            const SizedBox(height: 8),
            Text('Stats', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Views',
                    controller: _viewsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Likes',
                    controller: _likesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Comments',
                    controller: _commentsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
