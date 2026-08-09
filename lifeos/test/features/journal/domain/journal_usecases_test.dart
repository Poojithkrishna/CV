import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry.dart';
import 'package:lifeos/features/journal/domain/entities/journal_entry_type.dart';
import 'package:lifeos/features/journal/domain/repositories/journal_repository.dart';
import 'package:lifeos/features/journal/domain/usecases/create_journal_entry.dart';
import 'package:lifeos/features/journal/domain/usecases/delete_journal_entry.dart';
import 'package:lifeos/features/journal/domain/usecases/update_journal_entry.dart';

class _FakeJournalRepository implements JournalRepository {
  JournalEntry? savedEntry;
  String? deletedId;

  @override
  Future<Result<JournalEntry>> createEntry(JournalEntry entry) async {
    savedEntry = entry;
    return Result.ok(entry);
  }

  @override
  Future<Result<JournalEntry>> updateEntry(JournalEntry entry) async {
    savedEntry = entry;
    return Result.ok(entry);
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    deletedId = id;
    return const Result.ok(null);
  }

  @override
  Stream<JournalEntry?> watchEntry(String id) => const Stream.empty();

  @override
  Stream<List<JournalEntry>> watchAllEntries() => const Stream.empty();
}

JournalEntry _buildEntry({String content = 'Today was good.'}) {
  final DateTime now = DateTime(2026, 1, 1);
  return JournalEntry(
    id: 'e1',
    type: JournalEntryType.freeWriting,
    date: now,
    content: content,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateJournalEntry', () {
    test('persists an entry with non-blank content', () async {
      final repo = _FakeJournalRepository();
      final useCase = CreateJournalEntry(repo);

      final result = await useCase(_buildEntry());

      expect(result.isOk, isTrue);
      expect(repo.savedEntry?.content, 'Today was good.');
    });

    test('rejects blank content', () async {
      final repo = _FakeJournalRepository();
      final useCase = CreateJournalEntry(repo);

      final result = await useCase(_buildEntry(content: '   '));

      expect(result.isErr, isTrue);
      expect(repo.savedEntry, isNull);
    });
  });

  group('UpdateJournalEntry', () {
    test('persists a valid update', () async {
      final repo = _FakeJournalRepository();
      final useCase = UpdateJournalEntry(repo);

      final result = await useCase(_buildEntry(content: 'Updated thoughts.'));

      expect(result.isOk, isTrue);
      expect(repo.savedEntry?.content, 'Updated thoughts.');
    });

    test('rejects blank content', () async {
      final repo = _FakeJournalRepository();
      final useCase = UpdateJournalEntry(repo);

      final result = await useCase(_buildEntry(content: ''));

      expect(result.isErr, isTrue);
      expect(repo.savedEntry, isNull);
    });
  });

  group('DeleteJournalEntry', () {
    test('forwards the id to the repository', () async {
      final repo = _FakeJournalRepository();
      final useCase = DeleteJournalEntry(repo);

      final result = await useCase('e1');

      expect(result.isOk, isTrue);
      expect(repo.deletedId, 'e1');
    });
  });
}
