import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:lifeos/features/finance/domain/entities/investment.dart';
import 'package:lifeos/features/finance/domain/entities/investment_type.dart';
import 'package:lifeos/features/finance/domain/repositories/investment_repository.dart';
import 'package:lifeos/features/finance/domain/usecases/create_investment.dart';

class _FakeInvestmentRepository implements InvestmentRepository {
  Investment? saved;

  @override
  Future<Result<Investment>> createInvestment(Investment investment) async {
    saved = investment;
    return Result.ok(investment);
  }

  @override
  Future<Result<void>> deleteInvestment(String id) async => const Result.ok(null);

  @override
  Future<Result<Investment>> updateInvestment(Investment investment) async =>
      Result.ok(investment);

  @override
  Stream<Investment?> watchInvestment(String id) => const Stream.empty();

  @override
  Stream<List<Investment>> watchActiveInvestments() => const Stream.empty();
}

Investment _buildInvestment({double investedAmount = 1000, double currentValue = 1200}) {
  final DateTime now = DateTime(2026, 1, 1);
  return Investment(
    id: 'i1',
    name: 'Nifty 50 Index Fund',
    type: InvestmentType.mutualFund,
    investedAmount: investedAmount,
    currentValue: currentValue,
    colorValue: 0xFF7C4DFF,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CreateInvestment', () {
    test('persists a valid investment', () async {
      final repo = _FakeInvestmentRepository();
      final useCase = CreateInvestment(repo);

      final result = await useCase(_buildInvestment());

      expect(result.isOk, isTrue);
      expect(repo.saved?.name, 'Nifty 50 Index Fund');
    });

    test('rejects a blank name', () async {
      final repo = _FakeInvestmentRepository();
      final useCase = CreateInvestment(repo);

      final result = await useCase(_buildInvestment().copyWith(name: '  '));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative invested amount', () async {
      final repo = _FakeInvestmentRepository();
      final useCase = CreateInvestment(repo);

      final result = await useCase(_buildInvestment(investedAmount: -100));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });

    test('rejects a negative current value', () async {
      final repo = _FakeInvestmentRepository();
      final useCase = CreateInvestment(repo);

      final result = await useCase(_buildInvestment(currentValue: -1));

      expect(result.isErr, isTrue);
      expect(repo.saved, isNull);
    });
  });

  group('Investment.gainLoss / gainLossPercent', () {
    test('computes a positive gain', () {
      final investment = _buildInvestment(investedAmount: 1000, currentValue: 1200);
      expect(investment.gainLoss, 200);
      expect(investment.gainLossPercent, 20);
    });

    test('computes a loss', () {
      final investment = _buildInvestment(investedAmount: 1000, currentValue: 800);
      expect(investment.gainLoss, -200);
      expect(investment.gainLossPercent, -20);
    });

    test('gainLossPercent is zero when nothing was invested', () {
      final investment = _buildInvestment(investedAmount: 0, currentValue: 500);
      expect(investment.gainLossPercent, 0);
    });
  });
}
