import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/investments_dao.dart';
import '../../data/repositories/investment_repository_impl.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../../domain/usecases/create_investment.dart';
import '../../domain/usecases/delete_investment.dart';
import '../../domain/usecases/update_investment.dart';

final Provider<InvestmentsDao> investmentsDaoProvider = Provider<InvestmentsDao>((ref) {
  return InvestmentsDao(ref.watch(appDatabaseProvider));
});

final Provider<InvestmentRepository> investmentRepositoryProvider =
    Provider<InvestmentRepository>((ref) {
  return InvestmentRepositoryImpl(ref.watch(investmentsDaoProvider));
});

final Provider<CreateInvestment> createInvestmentUseCaseProvider = Provider(
  (ref) => CreateInvestment(ref.watch(investmentRepositoryProvider)),
);
final Provider<UpdateInvestment> updateInvestmentUseCaseProvider = Provider(
  (ref) => UpdateInvestment(ref.watch(investmentRepositoryProvider)),
);
final Provider<DeleteInvestment> deleteInvestmentUseCaseProvider = Provider(
  (ref) => DeleteInvestment(ref.watch(investmentRepositoryProvider)),
);

final StreamProvider<List<Investment>> activeInvestmentsProvider =
    StreamProvider<List<Investment>>((ref) {
  return ref.watch(investmentRepositoryProvider).watchActiveInvestments();
});

final StreamProviderFamily<Investment?, String> investmentByIdProvider =
    StreamProvider.family<Investment?, String>((ref, id) {
  return ref.watch(investmentRepositoryProvider).watchInvestment(id);
});
