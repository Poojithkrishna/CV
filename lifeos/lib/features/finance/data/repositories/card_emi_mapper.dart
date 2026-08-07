import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/card_emi.dart';

extension CardEmiRowMapper on CardEmiRow {
  CardEmi toDomain() {
    return CardEmi(
      id: id,
      cardId: cardId,
      description: description,
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      tenureMonths: tenureMonths,
      monthsPaid: monthsPaid,
      startDate: startDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension CardEmiEntityMapper on CardEmi {
  CardEmisCompanion toCompanion() {
    return CardEmisCompanion.insert(
      id: id,
      cardId: cardId,
      description: description,
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      tenureMonths: tenureMonths,
      monthsPaid: Value(monthsPaid),
      startDate: startDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
