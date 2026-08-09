import 'package:flutter/material.dart';

/// Which journaling prompt an entry was written under.
enum JournalEntryType {
  morning('Morning Journal', Icons.wb_sunny_outlined, Color(0xFFF59E0B)),
  night('Night Reflection', Icons.nightlight_outlined, Color(0xFF6366F1)),
  gratitude('Gratitude', Icons.favorite_outline_rounded, Color(0xFFEC4899)),
  freeWriting('Free Writing', Icons.edit_note_rounded, Color(0xFF14B8A6));

  const JournalEntryType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
