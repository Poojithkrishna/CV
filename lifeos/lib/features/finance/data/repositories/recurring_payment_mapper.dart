import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/recurrence_frequency.dart';
import '../../domain/entities/recurring_payment.dart';

extension RecurringPaymentRowMapper on RecurringPaymentRow {
  RecurringPayment toDomain() {
    return RecurringPayment(
      id: id,
      name: name,
      amount: amount,
      frequency: RecurrenceFrequency.values.byName(frequency),
      nextDueDate: nextDueDate,
      categoryId: categoryId,
      accountId: accountId,
      reminderDaysBefore: reminderDaysBefore,
      isAutoPay: isAutoPay,
      notes: notes,
      isArchived: isArchived,
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension RecurringPaymentEntityMapper on RecurringPayment {
  RecurringPaymentsCompanion toCompanion() {
    return RecurringPaymentsCompanion.insert(
      id: id,
      name: name,
      amount: amount,
      frequency: frequency.name,
      nextDueDate: nextDueDate,
      categoryId: Value(categoryId),
      accountId: Value(accountId),
      reminderDaysBefore: Value(reminderDaysBefore),
      isAutoPay: Value(isAutoPay),
      notes: Value(notes),
      isArchived: Value(isArchived),
      colorValue: colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
