import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/credit_card.dart';
import '../providers/credit_card_form_controller.dart';
import '../providers/credit_card_providers.dart';
import '../../../../core/widgets/color_theme_picker.dart';

final Uuid _uuid = Uuid();

class CreditCardFormScreen extends ConsumerStatefulWidget {
  const CreditCardFormScreen({super.key, this.cardId});

  final String? cardId;

  bool get isEditing => cardId != null;

  @override
  ConsumerState<CreditCardFormScreen> createState() => _CreditCardFormScreenState();
}

class _CreditCardFormScreenState extends ConsumerState<CreditCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _statementDayController = TextEditingController();
  final _dueDayController = TextEditingController();
  final _rewardPointsController = TextEditingController(text: '0');
  final _cashbackController = TextEditingController();
  final _annualFeeController = TextEditingController();
  final _notesController = TextEditingController();

  int _colorValue = AppGradients.palette.first.colors.first.value;
  CreditCard? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _creditLimitController.dispose();
    _statementDayController.dispose();
    _dueDayController.dispose();
    _rewardPointsController.dispose();
    _cashbackController.dispose();
    _annualFeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(CreditCard card) {
    _original = card;
    _nameController.text = card.name;
    _bankNameController.text = card.bankName ?? '';
    _creditLimitController.text = card.creditLimit.toStringAsFixed(2);
    _statementDayController.text = card.statementDay?.toString() ?? '';
    _dueDayController.text = card.dueDay?.toString() ?? '';
    _rewardPointsController.text = card.rewardPoints.toString();
    _cashbackController.text = card.cashbackEarned.toStringAsFixed(2);
    _annualFeeController.text = card.annualFee?.toStringAsFixed(2) ?? '';
    _notesController.text = card.notes ?? '';
    _colorValue = card.colorValue;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final CreditCard card = CreditCard(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
      currentUsage: _original?.currentUsage ?? 0,
      statementDay: int.tryParse(_statementDayController.text),
      dueDay: int.tryParse(_dueDayController.text),
      rewardPoints: int.tryParse(_rewardPointsController.text) ?? 0,
      cashbackEarned: double.tryParse(_cashbackController.text) ?? 0,
      annualFee: _annualFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_annualFeeController.text),
      colorValue: _colorValue,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(creditCardFormControllerProvider.notifier)
        .save(card, isEditing: widget.isEditing);

    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_prefilled) {
      final AsyncValue<CreditCard?> cardAsync = ref.watch(creditCardByIdProvider(widget.cardId!));
      return cardAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit card')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit card')),
          body: Center(child: Text('Could not load card: $error')),
        ),
        data: (CreditCard? card) {
          if (card == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit card')),
              body: const Center(child: Text('Card not found.')),
            );
          }
          _prefillFrom(card);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(creditCardFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit card' : 'New credit card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Card name',
              controller: _nameController,
              prefixIcon: Icons.credit_card_outlined,
              validator: (value) => Validators.required(value, field: 'Card name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Bank (optional)',
              controller: _bankNameController,
              prefixIcon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Credit limit',
              controller: _creditLimitController,
              prefixIcon: Icons.speed_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) {
                final double? parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a limit greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Statement day (optional)',
                    controller: _statementDayController,
                    keyboardType: TextInputType.number,
                    validator: (value) => _validateDay(value, 'Statement day'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Due day (optional)',
                    controller: _dueDayController,
                    keyboardType: TextInputType.number,
                    validator: (value) => _validateDay(value, 'Due day'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Reward points',
                    controller: _rewardPointsController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Cashback earned',
                    controller: _cashbackController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: decimalInputFormatters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Annual fee (optional)',
              controller: _annualFeeController,
              prefixIcon: Icons.receipt_long_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
            ),
            const SizedBox(height: 20),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ColorThemePicker(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes (optional)',
              controller: _notesController,
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Save changes' : 'Create card'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateDay(String? value, String field) {
    if (value == null || value.trim().isEmpty) return null;
    final int? parsed = int.tryParse(value);
    if (parsed == null || parsed < 1 || parsed > 31) return '$field must be between 1 and 31';
    return null;
  }
}
