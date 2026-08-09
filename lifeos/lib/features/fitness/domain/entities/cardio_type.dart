import 'package:flutter/material.dart';

enum CardioType {
  running('Running', Icons.directions_run_rounded),
  cycling('Cycling', Icons.directions_bike_rounded),
  swimming('Swimming', Icons.pool_rounded),
  walking('Walking', Icons.directions_walk_rounded),
  rowing('Rowing', Icons.rowing_rounded),
  elliptical('Elliptical', Icons.loop_rounded),
  other('Other', Icons.favorite_border_rounded);

  const CardioType(this.label, this.icon);

  final String label;
  final IconData icon;
}
