import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// Prompts for a single positive amount — used for quick actions like
/// "log a card payment" or "record a loan payment" that don't need a full
/// form screen. Returns `null` if the user cancels.
Future<double?> showAmountInputDialog(
  BuildContext context, {
  required String title,
  String label = 'Amount',
  double? maxAmount,
  double? initialValue,
}) async {
  final TextEditingController controller = TextEditingController(
    text: initialValue != null ? initialValue.toStringAsFixed(2) : '',
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final double? result = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: AppTextField(
          label: label,
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: decimalInputFormatters,
          validator: (value) {
            final double? parsed = double.tryParse(value ?? '');
            if (parsed == null || parsed <= 0) return 'Enter an amount greater than zero';
            if (maxAmount != null && parsed > maxAmount) {
              return 'Cannot exceed ${maxAmount.toStringAsFixed(2)}';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.of(context).pop(double.parse(controller.text));
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  return result;
}
