import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/investment.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_direction.dart';
import '../../domain/repositories/account_repository.dart';
import 'asset_providers.dart';
import 'credit_card_providers.dart';
import 'finance_providers.dart';
import 'investment_providers.dart';
import 'loan_providers.dart';

/// Net worth across every Finance sub-feature: account balances,
/// investments and other assets (always assets), credit card usage (a
/// liability) and loans (an asset when you're owed money, a liability
/// when you owe it) — computed straight from their live streams so it's
/// always in sync with the latest data, without a separate aggregate
/// query to keep consistent.
final Provider<AsyncValue<NetWorthSummary>> netWorthSummaryProvider =
    Provider<AsyncValue<NetWorthSummary>>((ref) {
  final AsyncValue<List<Account>> accountsAsync = ref.watch(activeAccountsProvider);
  final AsyncValue<List<CreditCard>> cardsAsync = ref.watch(activeCreditCardsProvider);
  final AsyncValue<List<Loan>> loansAsync = ref.watch(activeLoansProvider);
  final AsyncValue<List<Investment>> investmentsAsync = ref.watch(activeInvestmentsProvider);
  final AsyncValue<List<Asset>> assetsAsync = ref.watch(activeAssetsProvider);

  final List<Account>? accounts = accountsAsync.valueOrNull;
  final List<CreditCard>? cards = cardsAsync.valueOrNull;
  final List<Loan>? loans = loansAsync.valueOrNull;
  final List<Investment>? investments = investmentsAsync.valueOrNull;
  final List<Asset>? otherAssets = assetsAsync.valueOrNull;

  if (accounts == null || cards == null || loans == null || investments == null || otherAssets == null) {
    for (final AsyncValue<Object?> source in [
      accountsAsync,
      cardsAsync,
      loansAsync,
      investmentsAsync,
      assetsAsync,
    ]) {
      if (source.hasError) {
        return AsyncValue.error(source.error!, source.stackTrace ?? StackTrace.current);
      }
    }
    return const AsyncValue.loading();
  }

  double assets = 0;
  double liabilities = 0;

  for (final Account account in accounts) {
    if (account.type.isLiability) {
      liabilities += account.currentBalance.abs();
    } else {
      assets += account.currentBalance;
    }
  }
  for (final CreditCard card in cards) {
    liabilities += card.currentUsage;
  }
  for (final Loan loan in loans) {
    if (loan.direction == LoanDirection.given) {
      assets += loan.remainingAmount;
    } else {
      liabilities += loan.remainingAmount;
    }
  }
  for (final Investment investment in investments) {
    assets += investment.currentValue;
  }
  for (final Asset asset in otherAssets) {
    assets += asset.currentValue;
  }

  return AsyncValue.data(
    (assets: assets, liabilities: liabilities, netWorth: assets - liabilities),
  );
});
