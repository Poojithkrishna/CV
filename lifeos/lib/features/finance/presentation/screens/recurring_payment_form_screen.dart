import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/category_type.dart';
import '../../domain/entities/recurrence_frequency.dart';
import '../../domain/entities/recurring_payment.dart';
import '../providers/recurring_payment_form_controller.dart';
import '../providers/recurring_payment_providers.dart';
import '../widgets/account_picker_field.dart';
import '../widgets/category_picker_field.dart';
import '../widgets/color_theme_picker.dart';

final Uuid _uuid = Uuid();

class RecurringPaymentFormScreen extends ConsumerStatefulWidget {
  const RecurringPaymentFormScreen({super.key, this.paymentId});

  final String? paymentId;

  bool get isEditing => paymentId != null;

  @override
  ConsumerState<RecurringPaymentFormScreen> createState() => _RecurringPaymentFormScreenState();
}

class _RecurringPaymentFormScreenState extends ConsumerState<RecurringPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _reminderDaysController = TextEditingController();
  final _notesController = TextEditingController();

  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _nextDueDate = DateTime.now();
  String? _accountId;
  String? _categoryId;
  bool _isAutoPay = false;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  RecurringPayment? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _reminderDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(RecurringPayment payment) {
    _original = payment;
    _nameController.text = payment.name;
    _amountController.text = payment.amount.toStringAsFixed(2);
    _reminderDaysController.text = payment.reminderDaysBefore?.toString() ?? '';
    _notesController.text = payment.notes ?? '';
    _frequency = payment.frequency;
    _nextDueDate = payment.nextDueDate;
    _accountId = payment.accountId;
    _categoryId = payment.categoryId;
    _isAutoPay = payment.isAutoPay;
    _colorValue = payment.colorValue;
    _prefilled = true;
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _nextDueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final RecurringPayment payment = RecurringPayment(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      frequency: _frequency,
      nextDueDate: _nextDueDate,
      categoryId: _categoryId,
      accountId: _accountId,
      reminderDaysBefore: _reminderDaysController.text.trim().isEmpty
          ? null
          : int.tryParse(_reminderDaysController.text),
      isAutoPay: _isAutoPay,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      colorValue: _colorValue,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(recurringPaymentFormControllerProvider.notifier)
        .save(payment, isEditing: widget.isEditing);

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
      final AsyncValue<RecurringPayment?> paymentAsync =
          ref.watch(recurringPaymentByIdProvider(widget.paymentId!));
      return paymentAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit payment')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit payment')),
          body: Center(child: Text('Could not load payment: $error')),
        ),
        data: (RecurringPayment? payment) {
          if (payment == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit payment')),
              body: const Center(child: Text('Payment not found.')),
            );
          }
          _prefillFrom(payment);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(recurringPaymentFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit payment' : 'New bill or subscription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.receipt_long_outlined,
              validator: (value) => Validators.required(value, field: 'Name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount',
              controller: _amountController,
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
            Text('Repeats', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final RecurrenceFrequency frequency in RecurrenceFrequency.values)
                  ChoiceChip(
                    label: Text(frequency.label),
                    selected: frequency == _frequency,
                    onSelected: (_) => setState(() => _frequency = frequency),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text('Next due ${AppFormatters.shortDate(_nextDueDate)}'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 8),
            AccountPickerField(
              label: 'Account (optional)',
              selectedAccountId: _accountId,
              required: false,
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: 16),
            CategoryPickerField(
              type: CategoryType.expense,
              selectedCategoryId: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Remind me this many days before (optional)',
              controller: _reminderDaysController,
              prefixIcon: Icons.notifications_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final int? parsed = int.tryParse(value);
                if (parsed == null || parsed < 0) return 'Enter zero or more days';
                return null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-pay'),
              subtitle: const Text('This is deducted automatically'),
              value: _isAutoPay,
              onChanged: (value) => setState(() => _isAutoPay = value),
            ),
            const SizedBox(height: 12),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
