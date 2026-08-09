import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/photo_storage.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_status.dart';
import '../../domain/entities/media_type.dart';
import '../providers/media_item_form_controller.dart';
import '../providers/media_library_providers.dart';

final Uuid _uuid = Uuid();

class MediaItemFormScreen extends ConsumerStatefulWidget {
  const MediaItemFormScreen({super.key, this.itemId});

  final String? itemId;

  bool get isEditing => itemId != null;

  @override
  ConsumerState<MediaItemFormScreen> createState() => _MediaItemFormScreenState();
}

class _MediaItemFormScreenState extends ConsumerState<MediaItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _currentProgressController = TextEditingController(text: '0');
  final _totalProgressController = TextEditingController();
  final _ratingController = TextEditingController();
  final _notesController = TextEditingController();

  MediaType _type = MediaType.movie;
  MediaStatus _status = MediaStatus.wishlist;
  String? _coverImagePath;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  MediaItem? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _currentProgressController.dispose();
    _totalProgressController.dispose();
    _ratingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(MediaItem item) {
    _original = item;
    _titleController.text = item.title;
    _currentProgressController.text = '${item.currentProgress}';
    _totalProgressController.text = item.totalProgress?.toString() ?? '';
    _ratingController.text = item.rating?.toString() ?? '';
    _notesController.text = item.notes ?? '';
    _type = item.type;
    _status = item.status;
    _coverImagePath = item.coverImagePath;
    _colorValue = item.colorValue;
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

  Future<void> _pickCover() async {
    final ImageSource? source = await _pickSource(context);
    if (source == null) return;
    final XFile? picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final String savedPath = await saveImageFile(
      picked.path,
      _original?.id ?? _uuid.v4(),
      subdirectory: 'media_covers',
    );
    setState(() => _coverImagePath = savedPath);
  }

  String? _validateRating(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final double? parsed = double.tryParse(value);
    if (parsed == null) return 'Rating must be a valid number';
    if (parsed < 0 || parsed > 10) return 'Rating must be between 0 and 10';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final int currentProgress = int.tryParse(_currentProgressController.text) ?? 0;
    final int? totalProgress = int.tryParse(_totalProgressController.text);
    final double? rating = double.tryParse(_ratingController.text);

    final MediaItem item = MediaItem(
      id: _original?.id ?? _uuid.v4(),
      title: _titleController.text.trim(),
      type: _type,
      status: _status,
      currentProgress: currentProgress,
      totalProgress: totalProgress,
      rating: rating,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      coverImagePath: _coverImagePath,
      startedDate: _status == MediaStatus.inProgress
          ? (_original?.startedDate ?? now)
          : _original?.startedDate,
      completedDate: _status == MediaStatus.completed
          ? (_original?.completedDate ?? now)
          : _original?.completedDate,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(mediaItemFormControllerProvider.notifier)
        .save(item, isEditing: widget.isEditing);

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
      title: 'Delete this item?',
      message: 'This permanently removes it from your library.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteMediaItemUseCaseProvider).call(id);
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
      final AsyncValue<MediaItem?> itemAsync = ref.watch(mediaItemByIdProvider(widget.itemId!));
      return itemAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit item')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit item')),
          body: Center(child: Text('Could not load item: $error')),
        ),
        data: (MediaItem? item) {
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit item')),
              body: const Center(child: Text('Item not found.')),
            );
          }
          _prefillFrom(item);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(mediaItemFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit item' : 'Add to library'),
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
              onTap: _pickCover,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _coverImagePath == null
                      ? Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(Icons.add_photo_alternate_outlined, size: 32),
                          ),
                        )
                      : Image.file(File(_coverImagePath!), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Title',
              controller: _titleController,
              prefixIcon: Icons.title_rounded,
              validator: (value) => Validators.required(value, field: 'Title'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MediaType type in MediaType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Status', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MediaStatus status in MediaStatus.values)
                  ChoiceChip(
                    avatar: Icon(status.icon, size: 16),
                    label: Text(status.label),
                    selected: status == _status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Progress',
                    controller: _currentProgressController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppTextField(
                    label: 'Total (optional)',
                    controller: _totalProgressController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Rating out of 10 (optional)',
              controller: _ratingController,
              prefixIcon: Icons.star_outline_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: decimalInputFormatters,
              validator: _validateRating,
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
                  : Text(widget.isEditing ? 'Save changes' : 'Add to library'),
            ),
          ],
        ),
      ),
    );
  }
}
