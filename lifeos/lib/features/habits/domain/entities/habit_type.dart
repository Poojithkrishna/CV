import 'package:flutter/material.dart';

/// How a habit's progress is recorded each period. Every type except
/// [checklist] is tracked as a single numeric `progressValue` against the
/// habit's `targetValue` — [yesNo] is just that pattern with an implicit
/// target of 1, so the same storage and streak logic covers it without a
/// special case.
enum HabitType {
  yesNo('Yes / No', Icons.check_circle_outline),
  counter('Counter', Icons.tag_rounded),
  timer('Timer', Icons.timer_outlined),
  duration('Duration', Icons.hourglass_bottom_rounded),
  checklist('Checklist', Icons.checklist_rounded),
  collection('Collection', Icons.hub_outlined);

  const HabitType(this.label, this.icon);

  final String label;
  final IconData icon;

  bool get usesChecklistItems => this == HabitType.checklist;

  bool get usesNumericTarget => !usesChecklistItems;
}
