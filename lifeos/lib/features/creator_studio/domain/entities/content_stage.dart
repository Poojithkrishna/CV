import 'package:flutter/material.dart';

/// The production pipeline every piece of content moves through, in
/// order — see `ContentProject.stage`.
enum ContentStage {
  idea('Idea', Icons.lightbulb_outline_rounded),
  recording('Recording', Icons.videocam_outlined),
  editing('Editing', Icons.movie_creation_outlined),
  thumbnail('Thumbnail', Icons.image_outlined),
  upload('Upload', Icons.cloud_upload_outlined),
  published('Published', Icons.check_circle_outline_rounded);

  const ContentStage(this.label, this.icon);

  final String label;
  final IconData icon;

  ContentStage? get next {
    final int index = ContentStage.values.indexOf(this);
    if (index >= ContentStage.values.length - 1) return null;
    return ContentStage.values[index + 1];
  }

  ContentStage? get previous {
    final int index = ContentStage.values.indexOf(this);
    if (index <= 0) return null;
    return ContentStage.values[index - 1];
  }
}
