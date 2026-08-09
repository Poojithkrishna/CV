import 'package:flutter/material.dart';

enum ContentPlatform {
  youtube('YouTube', Icons.smart_display_outlined),
  twitch('Twitch', Icons.live_tv_outlined),
  tiktok('TikTok', Icons.music_note_outlined),
  instagram('Instagram', Icons.camera_alt_outlined),
  other('Other', Icons.public_outlined);

  const ContentPlatform(this.label, this.icon);

  final String label;
  final IconData icon;
}
