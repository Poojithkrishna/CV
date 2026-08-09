import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/progress_photo.dart';

class ProgressPhotoThumbnail extends StatelessWidget {
  const ProgressPhotoThumbnail({super.key, required this.photo, this.onTap});

  final ProgressPhoto photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Image.file(File(photo.filePath), fit: BoxFit.cover),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppFormatters.shortDate(photo.date),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
