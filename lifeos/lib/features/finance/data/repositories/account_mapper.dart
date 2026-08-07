import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';

/// Converts between the Drift-generated [AccountRow] (a plain data class
/// matching the SQL row shape) and the domain [Account] entity, so the rest
/// of the app never has to know about the persistence layer's types.
extension AccountRowMapper on AccountRow {
  Account toDomain() {
    return Account(
      id: id,
      name: name,
      type: AccountType.values.byName(accountType),
      currentBalance: currentBalance,
      openingBalance: openingBalance,
      colorValue: colorValue,
      bankName: bankName,
      accountNumber: accountNumber,
      interestRate: interestRate,
      iconCodePoint: iconCodePoint,
      backgroundImagePath: backgroundImagePath,
      notes: notes,
      isArchived: isArchived,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension AccountEntityMapper on Account {
  AccountsCompanion toCompanion() {
    return AccountsCompanion.insert(
      id: id,
      name: name,
      accountType: type.name,
      currentBalance: Value(currentBalance),
      openingBalance: Value(openingBalance),
      colorValue: colorValue,
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      interestRate: Value(interestRate),
      iconCodePoint: Value(iconCodePoint),
      backgroundImagePath: Value(backgroundImagePath),
      notes: Value(notes),
      isArchived: Value(isArchived),
      sortOrder: Value(sortOrder),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
