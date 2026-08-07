import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/card_emi.dart';
import 'package:lifeos/features/finance/domain/entities/credit_card.dart';
import 'package:lifeos/features/finance/domain/repositories/credit_card_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_credit_card.dart';

class _FakeCreditCardRepository implements CreditCardRepository {
  CreditCard? saved;

  @override
  Future<Result<CreditCard>> createCard(CreditCard card) async {
    saved = card;
    return Result.ok(card);
  }

  @override
  Future<Result<void>> adjustUsage(String cardId, double delta) async => const Result.ok(null);

  @override
  Future<Result<CardEmi>> createEmi(CardEmi emi) async => Result.ok(emi);

  @override
  Future<Result<void>> deleteCard(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> deleteEmi(String id) async => const Result.ok(null);

  @override
  Future<Result<void>> markEmiInstallmentPaid(String id) async => const Result.ok(null);

  @override
  Future<Result<CreditCard>> updateCard(CreditCard card) async => Result.ok(card);

  @override
  Stream<CreditCard?> watchCard(String id) => const Stream.empty();

  @override
  Stream<List<CreditCard>> watchActiveCards() => const Stream.empty();

  @override
  Stream<List<CardEmi>> watchEmisForCard(String cardId) => const Stream.empty();
}

CreditCard _buildCard({
  double creditLimit = 50000,
  int? statementDay,
  int? dueDay,
  double? annualFee,
}) {
  final DateTime now = DateTime(2026, 1, 1);
  return CreditCard(
    id: 'card-1',
    name: 'Test Card',
    creditLimit: creditLimit,
    colorValue: 0xFF7C4DFF,
    statementDay: statementDay,
    dueDay: dueDay,
    annualFee: annualFee,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateCreditCard', () {
    test('persists a valid card', () async {
      final repo = _FakeCreditCardRepository();
      final useCase = CreateCreditCard(repo);

      final result = await useCase(_buildCard());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Test Card');
    });

    test('rejects a credit limit of zero', () async {
      final repo = _FakeCreditCardRepository();
      final useCase = CreateCreditCard(repo);

      final result = await useCase(_buildCard(creditLimit: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects an out-of-range statement day', () async {
      final repo = _FakeCreditCardRepository();
      final useCase = CreateCreditCard(repo);

      final result = await useCase(_buildCard(statementDay: 32));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects an out-of-range due day', () async {
      final repo = _FakeCreditCardRepository();
      final useCase = CreateCreditCard(repo);

      final result = await useCase(_buildCard(dueDay: 0));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative annual fee', () async {
      final repo = _FakeCreditCardRepository();
      final useCase = CreateCreditCard(repo);

      final result = await useCase(_buildCard(annualFee: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });
}
