import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/credit_card.dart';

extension CreditCardRowMapper on CreditCardRow {
  CreditCard toDomain() {
    return CreditCard(
      id: id,
      name: name,
      bankName: bankName,
      creditLimit: creditLimit,
      currentUsage: currentUsage,
      statementDay: statementDay,
      dueDay: dueDay,
      rewardPoints: rewardPoints,
      cashbackEarned: cashbackEarned,
      annualFee: annualFee,
      colorValue: colorValue,
      notes: notes,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CreditCardEntityMapper on CreditCard {
  CreditCardsCompanion toCompanion() {
    return CreditCardsCompanion.insert(
      id: id,
      name: name,
      bankName: Value(bankName),
      creditLimit: creditLimit,
      currentUsage: Value(currentUsage),
      statementDay: Value(statementDay),
      dueDay: Value(dueDay),
      rewardPoints: Value(rewardPoints),
      cashbackEarned: Value(cashbackEarned),
      annualFee: Value(annualFee),
      colorValue: colorValue,
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
