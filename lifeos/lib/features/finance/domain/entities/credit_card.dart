import 'package:flutter/foundation.dart';

@immutable
class CreditCard {
  const CreditCard({
    required this.id,
    required this.name,
    required this.creditLimit,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.currentUsage = 0,
    this.bankName,
    this.statementDay,
    this.dueDay,
    this.rewardPoints = 0,
    this.cashbackEarned = 0,
    this.annualFee,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String? bankName;
  final double creditLimit;

  /// Amount currently owed on the card.
  final double currentUsage;

  /// Day of the month (1-31) the statement is generated, if known.
  final int? statementDay;

  /// Day of the month (1-31) payment is due, if known.
  final int? dueDay;

  final int rewardPoints;
  final double cashbackEarned;
  final double? annualFee;
  final int colorValue;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get availableCredit => creditLimit - currentUsage;

  /// 0-1 (can exceed 1 if the card is over its limit).
  double get utilization => creditLimit <= 0 ? 0 : currentUsage / creditLimit;

  bool get isOverLimit => currentUsage > creditLimit;

  CreditCard copyWith({
    String? name,
    String? bankName,
    bool clearBankName = false,
    double? creditLimit,
    double? currentUsage,
    int? statementDay,
    bool clearStatementDay = false,
    int? dueDay,
    bool clearDueDay = false,
    int? rewardPoints,
    double? cashbackEarned,
    double? annualFee,
    bool clearAnnualFee = false,
    int? colorValue,
    String? notes,
    bool clearNotes = false,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return CreditCard(
      id: id,
      name: name ?? this.name,
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      creditLimit: creditLimit ?? this.creditLimit,
      currentUsage: currentUsage ?? this.currentUsage,
      statementDay: clearStatementDay ? null : (statementDay ?? this.statementDay),
      dueDay: clearDueDay ? null : (dueDay ?? this.dueDay),
      rewardPoints: rewardPoints ?? this.rewardPoints,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      annualFee: clearAnnualFee ? null : (annualFee ?? this.annualFee),
      colorValue: colorValue ?? this.colorValue,
      notes: clearNotes ? null : (notes ?? this.notes),
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is CreditCard && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
