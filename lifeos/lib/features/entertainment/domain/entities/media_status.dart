import 'package:flutter/material.dart';

/// Where a [MediaItem] sits in the wishlist → in-progress → completed
/// (or dropped) lifecycle.
enum MediaStatus {
  wishlist('Wishlist', Icons.bookmark_border_rounded),
  inProgress('In Progress', Icons.play_circle_outline_rounded),
  completed('Completed', Icons.check_circle_outline_rounded),
  dropped('Dropped', Icons.cancel_outlined);

  const MediaStatus(this.label, this.icon);

  final String label;
  final IconData icon;
}
