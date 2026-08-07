import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/card_emi.dart';
import '../providers/credit_card_providers.dart';

final Uuid _uuid = Uuid();

/// Create form for a new EMI on [cardId]. EMIs aren't edited once created
/// (only paid down month by month or deleted) to keep the payoff math
/// unambiguous.
class CardEmiFormScreen extends ConsumerStatefulWidget {
  const CardEmiFormScreen({super.key, required this.cardId});

  final String cardId;

  @override
  ConsumerState<CardEmiFormScreen> createState() => _CardEmiFormScreenState();
}

class _CardEmiFormScreenState extends ConsumerState<CardEmiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _tenureController = TextEditingController();
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _monthlyAmountController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final DateTime now = DateTime.now();
    final CardEmi emi = CardEmi(
      id: _uuid.v4(),
      cardId: widget.cardId,
      description: _descriptionController.text.trim(),
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0,
      monthlyAmount: double.tryParse(_monthlyAmountController.text) ?? 0,
      tenureMonths: int.tryParse(_tenureController.text) ?? 0,
      startDate: _startDate,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createCardEmiUseCaseProvider).call(emi);
    if (!mounted) return;
    setState(() => _isSaving = false);

    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New EMI')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              prefixIcon: Icons.shopping_bag_outlined,
              validator: (value) => Validators.required(value, field: 'Description'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Total amount',
              controller: _totalAmountController,
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) {
                final double? parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) return 'Enter an amount greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Monthly amount',
                    controller: _monthlyAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                    validator: (value) {
                      final double? parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Tenure (months)',
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final int? parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text('Starts ${AppFormatters.shortDate(_startDate)}'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add EMI'),
            ),
          ],
        ),
      ),
    );
  }
}
