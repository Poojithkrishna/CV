import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

enum TransactionType {
  income('Income', Icons.arrow_downward_rounded, AppColors.income),
  expense('Expense', Icons.arrow_upward_rounded, AppColors.expense),
  transfer('Transfer', Icons.swap_horiz_rounded, AppColors.transfer);

  const TransactionType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
