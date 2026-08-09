import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/progress_photo.dart';
import '../providers/progress_photo_providers.dart';

class PhotoViewerScreen extends ConsumerWidget {
  const PhotoViewerScreen({super.key, required this.photo});

  final ProgressPhoto photo;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete photo?',
      message: 'This permanently removes the photo from your device.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteProgressPhotoUseCaseProvider).call(photo.id);
    if (!context.mounted) return;
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${photo.category.label} · ${AppFormatters.shortDate(photo.date)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(child: Image.file(File(photo.filePath))),
            ),
          ),
          if (photo.notes != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(photo.notes!, style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
    );
  }
}
