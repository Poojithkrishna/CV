import 'package:flutter/material.dart';

import '../../domain/entities/achievement.dart';

/// One achievement in the grid — full color and icon once unlocked,
/// greyed out with a lock overlay until then. The description is always
/// shown so locked achievements double as a checklist of what to do
/// next.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({super.key, required this.achievement, required this.isUnlocked});

  final Achievement achievement;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accent = isUnlocked ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Card(
      color: isUnlocked ? null : colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(achievement.icon, color: accent),
                const Spacer(),
                if (!isUnlocked) Icon(Icons.lock_outline_rounded, size: 16, color: accent),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isUnlocked ? null : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
