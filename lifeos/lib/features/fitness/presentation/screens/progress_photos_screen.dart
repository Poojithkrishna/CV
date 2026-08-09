import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/photo_storage.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/photo_category.dart';
import '../../domain/entities/progress_photo.dart';
import '../providers/progress_photo_providers.dart';
import '../widgets/progress_photo_thumbnail.dart';

final Uuid _uuid = Uuid();

class ProgressPhotosScreen extends ConsumerStatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  ConsumerState<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends ConsumerState<ProgressPhotosScreen> {
  PhotoCategory? _filter;

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

  Future<PhotoCategory?> _pickCategory(BuildContext context) {
    return showDialog<PhotoCategory>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Which angle?'),
        children: [
          for (final PhotoCategory category in PhotoCategory.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(category),
              child: Row(
                children: [
                  Icon(category.icon, size: 18),
                  const SizedBox(width: 12),
                  Text(category.label),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addPhoto(BuildContext context, WidgetRef ref) async {
    final ImageSource? source = await _pickSource(context);
    if (source == null) return;

    final XFile? picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    if (!context.mounted) return;

    final PhotoCategory? category = await _pickCategory(context);
    if (category == null) return;

    final String id = _uuid.v4();
    final String savedPath = await savePhotoFile(picked.path, id);
    final DateTime now = DateTime.now();
    final ProgressPhoto photo = ProgressPhoto(
      id: id,
      date: now,
      filePath: savedPath,
      category: category,
      createdAt: now,
    );

    final result = await ref.read(addProgressPhotoUseCaseProvider).call(photo);
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProgressPhoto>> photosAsync = _filter == null
        ? ref.watch(allProgressPhotosProvider)
        : ref.watch(photosByCategoryProvider(_filter!));

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Photos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPhoto(context, ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Photo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                for (final PhotoCategory category in PhotoCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: _filter == category,
                      onSelected: (_) => setState(() => _filter = category),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: photosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Something went wrong: $error')),
              data: (List<ProgressPhoto> photos) {
                if (photos.isEmpty) {
                  return EmptyState(
                    icon: Icons.photo_camera_outlined,
                    title: 'No photos yet',
                    message: 'Take a progress photo to start your visual timeline.',
                    actionLabel: 'Add a photo',
                    onAction: () => _addPhoto(context, ref),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final ProgressPhoto photo = photos[index];
                    return ProgressPhotoThumbnail(
                      photo: photo,
                      onTap: () => context.push('/fitness/progress-photos/view', extra: photo),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
