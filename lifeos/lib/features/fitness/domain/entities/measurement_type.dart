import 'package:flutter/material.dart';

/// Which body part a `MeasurementEntry` tracks. Each is stored as its own
/// per-date entry (see `MeasurementEntries`), so different parts don't
/// need to be logged together in one session.
enum MeasurementType {
  neck('Neck', Icons.accessibility_new_rounded),
  shoulders('Shoulders', Icons.accessibility_new_rounded),
  chest('Chest', Icons.accessibility_new_rounded),
  waist('Waist', Icons.straighten_rounded),
  hips('Hips', Icons.straighten_rounded),
  bicepLeft('Left Bicep', Icons.fitness_center_rounded),
  bicepRight('Right Bicep', Icons.fitness_center_rounded),
  forearm('Forearm', Icons.fitness_center_rounded),
  thighLeft('Left Thigh', Icons.straighten_rounded),
  thighRight('Right Thigh', Icons.straighten_rounded),
  calfLeft('Left Calf', Icons.straighten_rounded),
  calfRight('Right Calf', Icons.straighten_rounded);

  const MeasurementType(this.label, this.icon);

  final String label;
  final IconData icon;
}
