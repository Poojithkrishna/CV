import 'package:flutter/foundation.dart';

import 'account_type.dart';

/// Domain-level representation of a financial account, independent of how
/// it's persisted. UI and business logic depend on this, never on the
/// Drift-generated row class.
@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.openingBalance,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.bankName,
    this.accountNumber,
    this.interestRate,
    this.iconCodePoint,
    this.backgroundImagePath,
    this.notes,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final AccountType type;
  final double currentBalance;
  final double openingBalance;

  /// ARGB int for the account's chosen color/gradient theme.
  final int colorValue;

  final String? bankName;
  final String? accountNumber;
  final double? interestRate;

  /// Code point of a custom [IconData] the user picked; falls back to
  /// [AccountType.defaultIcon] when null.
  final int? iconCodePoint;

  final String? backgroundImagePath;
  final String? notes;
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Net change since the account was opened.
  double get netChange => currentBalance - openingBalance;

  /// Signed contribution to net worth: liabilities (loans, credit card
  /// balances) subtract rather than add.
  double get netWorthContribution => type.isLiability ? -currentBalance.abs() : currentBalance;

  String get maskedAccountNumber {
    final String? number = accountNumber;
    if (number == null || number.length < 4) return number ?? '';
    return '•••• ${number.substring(number.length - 4)}';
  }

  Account copyWith({
    String? name,
    AccountType? type,
    double? currentBalance,
    double? openingBalance,
    int? colorValue,
    String? bankName,
    bool clearBankName = false,
    String? accountNumber,
    bool clearAccountNumber = false,
    double? interestRate,
    bool clearInterestRate = false,
    int? iconCodePoint,
    bool clearIconCodePoint = false,
    String? backgroundImagePath,
    bool clearBackgroundImagePath = false,
    String? notes,
    bool clearNotes = false,
    bool? isArchived,
    int? sortOrder,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      openingBalance: openingBalance ?? this.openingBalance,
      colorValue: colorValue ?? this.colorValue,
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      accountNumber: clearAccountNumber ? null : (accountNumber ?? this.accountNumber),
      interestRate: clearInterestRate ? null : (interestRate ?? this.interestRate),
      iconCodePoint: clearIconCodePoint ? null : (iconCodePoint ?? this.iconCodePoint),
      backgroundImagePath: clearBackgroundImagePath
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      notes: clearNotes ? null : (notes ?? this.notes),
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Account && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
