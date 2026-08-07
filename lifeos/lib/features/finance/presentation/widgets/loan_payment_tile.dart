import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/loan_payment.dart';

class LoanPaymentTile extends StatelessWidget {
  const LoanPaymentTile({super.key, required this.payment, required this.onDelete});

  final LoanPayment payment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.payments_outlined, size: 18)),
        title: Text(AppFormatters.currency(payment.amount)),
        subtitle: Text(
          payment.note?.isNotEmpty == true
              ? '${AppFormatters.shortDate(payment.date)} · ${payment.note}'
              : AppFormatters.shortDate(payment.date),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
