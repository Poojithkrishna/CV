import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../daos/investments_dao.dart';
import 'investment_mapper.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  InvestmentRepositoryImpl(this._dao);

  final InvestmentsDao _dao;

  @override
  Stream<List<Investment>> watchActiveInvestments() {
    return _dao
        .watchActiveInvestments()
        .map((rows) => rows.map((row) => row.toDomain()).toList(growable: false));
  }

  @override
  Stream<Investment?> watchInvestment(String id) {
    return _dao.watchInvestment(id).map((row) => row?.toDomain());
  }

  @override
  Future<Result<Investment>> createInvestment(Investment investment) async {
    try {
      await _dao.insertInvestment(investment.toCompanion());
      return Result.ok(investment);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not save investment: $e'));
    }
  }

  @override
  Future<Result<Investment>> updateInvestment(Investment investment) async {
    try {
      final bool updated = await _dao.updateInvestment(investment.toCompanion());
      if (!updated) {
        return const Result.err(NotFoundFailure('Investment no longer exists.'));
      }
      return Result.ok(investment);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not update investment: $e'));
    }
  }

  @override
  Future<Result<void>> deleteInvestment(String id) async {
    try {
      await _dao.deleteInvestment(id);
      return const Result.ok(null);
    } catch (e) {
      return Result.err(DatabaseFailure('Could not delete investment: $e'));
    }
  }
}
