import 'package:flutter/material.dart';

import '../../domain/entities/exercise.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({super.key, required this.exercise, this.onTap, this.trailing});

  final Exercise exercise;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHigh,
          child: Icon(exercise.equipment.icon, color: colorScheme.primary, size: 20),
        ),
        title: Text(exercise.name, overflow: TextOverflow.ellipsis),
        subtitle: Text('${exercise.muscleGroup.label} · ${exercise.equipment.label}'),
        trailing: trailing,
      ),
    );
  }
}
