import 'package:flutter/material.dart';

/// The kinds of accounts Demon Origin's Finance module can track. Credit cards
/// and loans get their own richer modules later; a credit card can still
/// be represented here as a lightweight account so it rolls up into net
/// worth before the dedicated Credit Cards feature lands.
enum AccountType {
  bank('Bank Account', Icons.account_balance_rounded),
  cash('Cash', Icons.payments_rounded),
  wallet('Digital Wallet', Icons.account_balance_wallet_rounded),
  savings('Savings', Icons.savings_rounded),
  creditCard('Credit Card', Icons.credit_card_rounded),
  investment('Investment', Icons.trending_up_rounded),
  loan('Loan', Icons.handshake_rounded),
  other('Other', Icons.category_rounded);

  const AccountType(this.label, this.defaultIcon);

  final String label;
  final IconData defaultIcon;

  /// Whether this account type's balance should be subtracted (rather than
  /// added) when rolling up net worth — e.g. an outstanding loan or credit
  /// card balance is a liability, not an asset.
  bool get isLiability => this == AccountType.loan || this == AccountType.creditCard;
}
