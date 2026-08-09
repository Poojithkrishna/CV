import '../../../../core/utils/result.dart';
import '../entities/investment.dart';

abstract interface class InvestmentRepository {
  Stream<List<Investment>> watchActiveInvestments();
  Stream<Investment?> watchInvestment(String id);

  Future<Result<Investment>> createInvestment(Investment investment);
  Future<Result<Investment>> updateInvestment(Investment investment);
  Future<Result<void>> deleteInvestment(String id);
}
