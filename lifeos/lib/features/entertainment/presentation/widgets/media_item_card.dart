import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/widgets/labeled_progress_bar.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/services/media_library_stats.dart';

/// A single library entry: cover (or a type-icon fallback), title, type +
/// status, an optional progress bar and a quick "+1" button for nudging
/// progress without opening the full form.
class MediaItemCard extends StatelessWidget {
  const MediaItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLogProgress,
  });

  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback? onLogProgress;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(item.colorValue);
    final double? progress = MediaLibraryStats.progressFraction(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: item.coverImagePath != null
                      ? Image.file(File(item.coverImagePath!), fit: BoxFit.cover)
                      : Container(
                          color: color.withOpacity(0.12),
                          alignment: Alignment.center,
                          child: Icon(item.type.icon, color: color),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(item.status.icon, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          '${item.type.label} · ${item.status.label}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (item.rating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          Text(
                            item.rating!.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      LabeledProgressBar(
                        progress: progress,
                        leadingLabel: '${item.currentProgress} / ${item.totalProgress}',
                        trailingLabel: '${(progress * 100).toStringAsFixed(0)}%',
                        color: color,
                      ),
                    ],
                  ],
                ),
              ),
              if (onLogProgress != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: 'Log progress',
                  onPressed: onLogProgress,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
