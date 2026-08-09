import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/content_project.dart';

/// A single pipeline kanban card — thumbnail (if any), title, game and
/// platform, with buttons to nudge it to the previous/next stage without
/// opening the full form.
class ContentProjectCard extends StatelessWidget {
  const ContentProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onMoveBack,
    required this.onMoveForward,
  });

  final ContentProject project;
  final VoidCallback onTap;
  final VoidCallback? onMoveBack;
  final VoidCallback? onMoveForward;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(project.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.thumbnailPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(File(project.thumbnailPath!), fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(project.platform.icon, color: color),
                ),
              const SizedBox(height: 10),
              Text(
                project.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.game.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  project.game,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(project.platform.icon, size: 16, color: color),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.chevron_left_rounded, size: 20),
                        onPressed: onMoveBack,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.chevron_right_rounded, size: 20),
                        onPressed: onMoveForward,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
