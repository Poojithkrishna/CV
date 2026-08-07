import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard labeled text field used across every module's forms, so
/// spacing, label style and validation rendering stay consistent.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}

/// Common numeric input formatter allowing digits and a single decimal
/// point — used for balance / amount / interest-rate fields.
final List<TextInputFormatter> decimalInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
];
