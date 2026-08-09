import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/investment.dart';
import '../../domain/entities/investment_type.dart';

extension InvestmentRowMapper on InvestmentRow {
  Investment toDomain() {
    return Investment(
      id: id,
      name: name,
      type: InvestmentType.values.byName(type),
      investedAmount: investedAmount,
      currentValue: currentValue,
      purchaseDate: purchaseDate,
      notes: notes,
      colorValue: colorValue,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension InvestmentEntityMapper on Investment {
  InvestmentsCompanion toCompanion() {
    return InvestmentsCompanion.insert(
      id: id,
      name: name,
      type: type.name,
      investedAmount: Value(investedAmount),
      currentValue: Value(currentValue),
      purchaseDate: Value(purchaseDate),
      notes: Value(notes),
      colorValue: colorValue,
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
