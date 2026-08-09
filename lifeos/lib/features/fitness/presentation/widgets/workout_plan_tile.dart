import 'package:flutter/material.dart';

import '../../domain/entities/workout_plan.dart';

class WorkoutPlanTile extends StatelessWidget {
  const WorkoutPlanTile({
    super.key,
    required this.plan,
    this.onTap,
    this.onSetActive,
  });

  final WorkoutPlan plan;
  final VoidCallback? onTap;
  final VoidCallback? onSetActive;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(plan.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: plan.isActive ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.18),
          child: Icon(plan.type.icon, color: color, size: 20),
        ),
        title: Text(plan.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(plan.type.label),
        trailing: plan.isActive
            ? Chip(
                label: const Text('Active'),
                backgroundColor: color.withOpacity(0.18),
                labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
                side: BorderSide.none,
              )
            : TextButton(
                onPressed: onSetActive,
                child: const Text('Set active'),
              ),
      ),
    );
  }
}
