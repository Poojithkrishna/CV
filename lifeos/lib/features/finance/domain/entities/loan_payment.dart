import 'package:flutter/foundation.dart';

@immutable
class LoanPayment {
  const LoanPayment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String loanId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) => other is LoanPayment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
