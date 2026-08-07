import 'package:flutter/foundation.dart';

/// A purchase converted into equal monthly installments on a credit
/// card. Tracked independently of the card's [CreditCard.currentUsage] —
/// banks handle the accounting differently card to card, so rather than
/// guess, this just tracks the EMI's own payoff progress; the cardholder
/// updates usage themselves via the card's charge/payment actions.
@immutable
class CardEmi {
  const CardEmi({
    required this.id,
    required this.cardId,
    required this.description,
    required this.totalAmount,
    required this.monthlyAmount,
    required this.tenureMonths,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    this.monthsPaid = 0,
  });

  final String id;
  final String cardId;
  final String description;
  final double totalAmount;
  final double monthlyAmount;
  final int tenureMonths;
  final int monthsPaid;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get remainingMonths => (tenureMonths - monthsPaid).clamp(0, tenureMonths);

  double get remainingAmount => (totalAmount - (monthlyAmount * monthsPaid)).clamp(0, totalAmount);

  bool get isPaidOff => monthsPaid >= tenureMonths;

  double get progress => tenureMonths == 0 ? 1 : (monthsPaid / tenureMonths).clamp(0, 1);

  CardEmi copyWith({
    String? description,
    double? totalAmount,
    double? monthlyAmount,
    int? tenureMonths,
    int? monthsPaid,
    DateTime? startDate,
    DateTime? updatedAt,
  }) {
    return CardEmi(
      id: id,
      cardId: cardId,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is CardEmi && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
