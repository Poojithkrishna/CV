import 'package:flutter/foundation.dart';

import 'loan_direction.dart';

@immutable
class Loan {
  const Loan({
    required this.id,
    required this.direction,
    required this.personName,
    required this.principalAmount,
    required this.remainingAmount,
    required this.createdAt,
    required this.updatedAt,
    this.personPhone,
    this.dueDate,
    this.reminderEnabled = false,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final LoanDirection direction;
  final String personName;
  final String? personPhone;
  final double principalAmount;
  final double remainingAmount;
  final DateTime? dueDate;
  final bool reminderEnabled;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get amountPaid => principalAmount - remainingAmount;

  bool get isSettled => remainingAmount <= 0;

  double get progress =>
      principalAmount <= 0 ? 1 : (amountPaid / principalAmount).clamp(0, 1).toDouble();

  /// Signed contribution to net worth: a loan given is money owed to you
  /// (an asset); a loan borrowed is money you owe (a liability).
  double get netWorthContribution =>
      direction == LoanDirection.given ? remainingAmount : -remainingAmount;

  Loan copyWith({
    LoanDirection? direction,
    String? personName,
    String? personPhone,
    bool clearPersonPhone = false,
    double? principalAmount,
    double? remainingAmount,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? reminderEnabled,
    String? notes,
    bool clearNotes = false,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id,
      direction: direction ?? this.direction,
      personName: personName ?? this.personName,
      personPhone: clearPersonPhone ? null : (personPhone ?? this.personPhone),
      principalAmount: principalAmount ?? this.principalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notes: clearNotes ? null : (notes ?? this.notes),
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Loan && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
