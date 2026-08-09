import 'package:flutter/material.dart';

/// A 1-5 mood scale attached to a journal entry, entirely optional — not
/// every entry needs a mood logged against it.
enum Mood {
  terrible(1, 'Terrible', Icons.sentiment_very_dissatisfied_rounded),
  bad(2, 'Bad', Icons.sentiment_dissatisfied_rounded),
  okay(3, 'Okay', Icons.sentiment_neutral_rounded),
  good(4, 'Good', Icons.sentiment_satisfied_rounded),
  great(5, 'Great', Icons.sentiment_very_satisfied_rounded);

  const Mood(this.value, this.label, this.icon);

  final int value;
  final String label;
  final IconData icon;
}
