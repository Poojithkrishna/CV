import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_direction.dart';
import '../../domain/entities/loan_payment.dart';

extension LoanRowMapper on LoanRow {
  Loan toDomain() {
    return Loan(
      id: id,
      direction: LoanDirection.values.byName(direction),
      personName: personName,
      personPhone: personPhone,
      principalAmount: principalAmount,
      remainingAmount: remainingAmount,
      dueDate: dueDate,
      reminderEnabled: reminderEnabled,
      notes: notes,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension LoanEntityMapper on Loan {
  LoansCompanion toCompanion() {
    return LoansCompanion.insert(
      id: id,
      direction: direction.name,
      personName: personName,
      personPhone: Value(personPhone),
      principalAmount: principalAmount,
      remainingAmount: remainingAmount,
      dueDate: Value(dueDate),
      reminderEnabled: Value(reminderEnabled),
      notes: Value(notes),
      isArchived: Value(isArchived),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension LoanPaymentRowMapper on LoanPaymentRow {
  LoanPayment toDomain() {
    return LoanPayment(
      id: id,
      loanId: loanId,
      amount: amount,
      date: date,
      note: note,
      createdAt: createdAt,
    );
  }
}

extension LoanPaymentEntityMapper on LoanPayment {
  LoanPaymentsCompanion toCompanion() {
    return LoanPaymentsCompanion.insert(
      id: id,
      loanId: loanId,
      amount: amount,
      date: date,
      note: Value(note),
      createdAt: createdAt,
    );
  }
}
