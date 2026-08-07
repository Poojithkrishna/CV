import 'package:flutter/material.dart';

/// Prompts for a single line of required text — used for quick actions
/// like naming a new workout day that don't need a full form screen.
/// Returns `null` if the user cancels.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String label = 'Name',
  String? initialValue,
  String confirmLabel = 'Save',
}) async {
  final TextEditingController controller = TextEditingController(text: initialValue ?? '');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final String? result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'This field is required' : null,
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
              Navigator.of(context).pop(controller.text.trim());
            }
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return result;
}
