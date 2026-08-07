import 'package:flutter/foundation.dart';

import 'recurrence_frequency.dart';

@immutable
class RecurringPayment {
  const RecurringPayment({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.accountId,
    this.reminderDaysBefore,
    this.isAutoPay = false,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;

  /// Expected amount; the actual amount can be adjusted when marking a
  /// specific occurrence paid (e.g. a variable electricity bill).
  final double amount;

  final RecurrenceFrequency frequency;
  final DateTime nextDueDate;

  final String? categoryId;

  /// When set, "mark as paid" logs a real expense transaction against
  /// this account instead of just advancing the schedule.
  final String? accountId;

  final int? reminderDaysBefore;
  final bool isAutoPay;
  final String? notes;
  final bool isArchived;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get daysUntilDue {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime dueDate = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    return dueDate.difference(todayDate).inDays;
  }

  bool get isOverdue => daysUntilDue < 0;

  bool get isDueSoon =>
      !isOverdue && reminderDaysBefore != null && daysUntilDue <= reminderDaysBefore!;

  RecurringPayment copyWith({
    String? name,
    double? amount,
    RecurrenceFrequency? frequency,
    DateTime? nextDueDate,
    String? categoryId,
    bool clearCategoryId = false,
    String? accountId,
    bool clearAccountId = false,
    int? reminderDaysBefore,
    bool clearReminderDaysBefore = false,
    bool? isAutoPay,
    String? notes,
    bool clearNotes = false,
    bool? isArchived,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return RecurringPayment(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      reminderDaysBefore:
          clearReminderDaysBefore ? null : (reminderDaysBefore ?? this.reminderDaysBefore),
      isAutoPay: isAutoPay ?? this.isAutoPay,
      notes: clearNotes ? null : (notes ?? this.notes),
      isArchived: isArchived ?? this.isArchived,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is RecurringPayment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
