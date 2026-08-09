import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_session.dart';
import 'package:lifeos/features/fitness/domain/entities/cardio_type.dart';
import 'package:lifeos/features/fitness/domain/repositories/cardio_session_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/log_cardio_session.dart';

class _FakeCardioSessionRepository implements CardioSessionRepository {
  CardioSession? saved;

  @override
  Future<Result<void>> deleteSession(String id) async => const Result.ok(null);

  @override
  Future<Result<CardioSession>> logSession(CardioSession session) async {
    saved = session;
    return Result.ok(session);
  }

  @override
  Future<Result<CardioSession>> updateSession(CardioSession session) async => Result.ok(session);

  @override
  Stream<CardioSession?> watchSession(String id) => const Stream.empty();

  @override
  Stream<List<CardioSession>> watchAllSessions() => const Stream.empty();
}

CardioSession _buildSession({double durationMinutes = 30, double? distanceKm, double? caloriesBurned}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CardioSession(
    id: 's1',
    type: CardioType.running,
    date: now,
    durationMinutes: durationMinutes,
    distanceKm: distanceKm,
    caloriesBurned: caloriesBurned,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('LogCardioSession', () {
    test('persists a valid session', () async {
      final repo = _FakeCardioSessionRepository();
      final useCase = LogCardioSession(repo);

      final result = await useCase(_buildSession(durationMinutes: 45, distanceKm: 8));

      expect(result.isOk, isTrue);
      expect(repo.saved?.durationMinutes, 45);
    });

    test('rejects a zero duration', () async {
      final repo = _FakeCardioSessionRepository();
      final useCase = LogCardioSession(repo);

      final result = await useCase(_buildSession(durationMinutes: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative distance', () async {
      final repo = _FakeCardioSessionRepository();
      final useCase = LogCardioSession(repo);

      final result = await useCase(_buildSession(distanceKm: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects negative calories burned', () async {
      final repo = _FakeCardioSessionRepository();
      final useCase = LogCardioSession(repo);

      final result = await useCase(_buildSession(caloriesBurned: -5));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
