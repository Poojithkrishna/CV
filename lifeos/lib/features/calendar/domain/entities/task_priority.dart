import 'package:flutter/material.dart';

enum TaskPriority {
  low('Low', Icons.arrow_downward_rounded, Color(0xFF3B82F6)),
  medium('Medium', Icons.remove_rounded, Color(0xFFF59E0B)),
  high('High', Icons.arrow_upward_rounded, Color(0xFFEF4444));

  const TaskPriority(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
