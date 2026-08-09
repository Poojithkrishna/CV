import 'package:flutter/material.dart';

enum InvestmentType {
  stocks('Stocks', Icons.show_chart_rounded),
  mutualFund('Mutual Fund', Icons.pie_chart_outline_rounded),
  crypto('Crypto', Icons.currency_bitcoin_rounded),
  bonds('Bonds', Icons.account_balance_rounded),
  retirement('Retirement', Icons.savings_outlined),
  gold('Gold', Icons.workspace_premium_outlined),
  other('Other', Icons.trending_up_rounded);

  const InvestmentType(this.label, this.icon);

  final String label;
  final IconData icon;
}
