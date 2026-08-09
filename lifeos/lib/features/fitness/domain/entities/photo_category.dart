import 'package:flutter/material.dart';

enum PhotoCategory {
  front('Front', Icons.accessibility_new_rounded),
  side('Side', Icons.accessibility_new_rounded),
  back('Back', Icons.accessibility_new_rounded),
  other('Other', Icons.photo_camera_outlined);

  const PhotoCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
