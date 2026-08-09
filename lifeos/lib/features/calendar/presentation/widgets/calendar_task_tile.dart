import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/calendar_task.dart';

/// A single task row: a checkbox that toggles done/undone without
/// opening the full form, title (struck through once done), priority
/// dot and due date/time-block info.
class CalendarTaskTile extends StatelessWidget {
  const CalendarTaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleDone,
  });

  final CalendarTask task;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = task.priority.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: task.isDone, onChanged: (_) => onToggleDone()),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Theme.of(context).colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: task.dueDate == null
            ? null
            : Text(
                task.isTimeBlocked
                    ? AppFormatters.time(task.dueDate!)
                    : AppFormatters.relativeDay(task.dueDate!),
              ),
        trailing: Icon(Icons.circle, size: 10, color: priorityColor),
      ),
    );
  }
}
