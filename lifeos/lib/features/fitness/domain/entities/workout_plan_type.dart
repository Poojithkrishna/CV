import 'package:flutter/material.dart';

enum WorkoutPlanType {
  gym('Gym', Icons.fitness_center_rounded),
  home('Home', Icons.home_rounded),
  dumbbells('Dumbbells', Icons.sports_gymnastics_rounded),
  bodyweight('Bodyweight', Icons.accessibility_new_rounded),
  resistanceBands('Resistance Bands', Icons.linear_scale_rounded),
  travel('Travel', Icons.flight_takeoff_rounded);

  const WorkoutPlanType(this.label, this.icon);

  final String label;
  final IconData icon;
}
