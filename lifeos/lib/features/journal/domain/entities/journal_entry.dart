import 'package:flutter/foundation.dart';

import 'journal_entry_type.dart';
import 'mood.dart';

/// A single journal entry — a morning journal, night reflection,
/// gratitude list or free writing piece, written for [date] with an
/// optional mood attached.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
  });

  final String id;
  final JournalEntryType type;

  /// The day this entry is journaled for — not necessarily [createdAt],
  /// since an entry can be back-dated.
  final DateTime date;

  final String content;
  final Mood? mood;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry copyWith({
    JournalEntryType? type,
    DateTime? date,
    String? content,
    Mood? mood,
    bool clearMood = false,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id,
      type: type ?? this.type,
      date: date ?? this.date,
      content: content ?? this.content,
      mood: clearMood ? null : (mood ?? this.mood),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is JournalEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
