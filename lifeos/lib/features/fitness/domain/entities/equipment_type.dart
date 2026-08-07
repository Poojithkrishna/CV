import 'package:flutter/material.dart';

/// What an exercise needs to perform it. Distinct from [WorkoutPlanType]
/// (which describes an entire plan's setting) — a single Gym plan can
/// still include a bodyweight exercise like push-ups.
enum EquipmentType {
  barbell('Barbell', Icons.fitness_center_rounded),
  dumbbell('Dumbbell', Icons.sports_gymnastics_rounded),
  machine('Machine', Icons.precision_manufacturing_outlined),
  bodyweight('Bodyweight', Icons.accessibility_new_rounded),
  resistanceBand('Resistance Band', Icons.linear_scale_rounded),
  cardio('Cardio', Icons.directions_run_rounded),
  other('Other', Icons.category_outlined);

  const EquipmentType(this.label, this.icon);

  final String label;
  final IconData icon;
}
