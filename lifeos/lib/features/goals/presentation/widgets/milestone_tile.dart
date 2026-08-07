import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/milestone.dart';

class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    super.key,
    required this.milestone,
    required this.onToggle,
    required this.onDelete,
  });

  final Milestone milestone;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: milestone.isCompleted,
      onChanged: (_) => onToggle(),
      title: Text(
        milestone.title,
        style: TextStyle(
          decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: milestone.targetDate != null
          ? Text(AppFormatters.shortDate(milestone.targetDate!))
          : null,
      secondary: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: onDelete,
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
