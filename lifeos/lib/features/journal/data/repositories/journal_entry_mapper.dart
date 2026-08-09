import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/journal_entry_type.dart';
import '../../domain/entities/mood.dart';

extension JournalEntryRowMapper on JournalEntryRow {
  JournalEntry toDomain() {
    return JournalEntry(
      id: id,
      type: JournalEntryType.values.byName(type),
      date: date,
      content: content,
      mood: mood == null ? null : Mood.values.byName(mood!),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension JournalEntryEntityMapper on JournalEntry {
  JournalEntriesCompanion toCompanion() {
    return JournalEntriesCompanion.insert(
      id: id,
      type: type.name,
      date: date,
      content: content,
      mood: Value(mood?.name),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
