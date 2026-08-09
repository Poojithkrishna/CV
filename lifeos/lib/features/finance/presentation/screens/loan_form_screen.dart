import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/notification_provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_direction.dart';
import '../notifications/loan_reminders.dart';
import '../providers/loan_form_controller.dart';
import '../providers/loan_providers.dart';

final Uuid _uuid = Uuid();

class LoanFormScreen extends ConsumerStatefulWidget {
  const LoanFormScreen({super.key, this.loanId});

  final String? loanId;

  bool get isEditing => loanId != null;

  @override
  ConsumerState<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends ConsumerState<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _personPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  LoanDirection _direction = LoanDirection.given;
  DateTime? _dueDate;
  bool _reminderEnabled = false;
  Loan? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _personNameController.dispose();
    _personPhoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Loan loan) {
    _original = loan;
    _direction = loan.direction;
    _personNameController.text = loan.personName;
    _personPhoneController.text = loan.personPhone ?? '';
    _amountController.text = loan.principalAmount.toStringAsFixed(2);
    _notesController.text = loan.notes ?? '';
    _dueDate = loan.dueDate;
    _reminderEnabled = loan.reminderEnabled;
    _prefilled = true;
  }

  Future<void> _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final double principal = double.tryParse(_amountController.text) ?? 0;

    final Loan loan = Loan(
      id: _original?.id ?? _uuid.v4(),
      direction: _direction,
      personName: _personNameController.text.trim(),
      personPhone:
          _personPhoneController.text.trim().isEmpty ? null : _personPhoneController.text.trim(),
      principalAmount: principal,
      // A brand-new loan starts fully outstanding; editing preserves
      // whatever remains after any recorded payments.
      remainingAmount: _original?.remainingAmount ?? principal,
      dueDate: _dueDate,
      reminderEnabled: _reminderEnabled,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(loanFormControllerProvider.notifier)
        .save(loan, isEditing: widget.isEditing);

    if (!mounted) return;

    if (result.isOk) {
      await syncLoanReminder(ref.read(notificationServiceProvider), result.valueOrNull!);
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failureOrNull!.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing && !_prefilled) {
      final AsyncValue<Loan?> loanAsync = ref.watch(loanByIdProvider(widget.loanId!));
      return loanAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit loan')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit loan')),
          body: Center(child: Text('Could not load loan: $error')),
        ),
        data: (Loan? loan) {
          if (loan == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit loan')),
              body: const Center(child: Text('Loan not found.')),
            );
          }
          _prefillFrom(loan);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(loanFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit loan' : 'New loan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Center(
              child: SegmentedButton<LoanDirection>(
                segments: [
                  for (final LoanDirection direction in LoanDirection.values)
                    ButtonSegment(value: direction, label: Text(direction.label)),
                ],
                selected: {_direction},
                onSelectionChanged: (selection) =>
                    setState(() => _direction = selection.first),
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Person\'s name',
              controller: _personNameController,
              prefixIcon: Icons.person_outline,
              validator: (value) => Validators.required(value, field: 'Person\'s name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone (optional)',
              controller: _personPhoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
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
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_dueDate != null
                  ? 'Due ${AppFormatters.shortDate(_dueDate!)}'
                  : 'No due date'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDueDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remind me before it\'s due'),
              value: _reminderEnabled,
              onChanged: _dueDate == null
                  ? null
                  : (value) => setState(() => _reminderEnabled = value),
            ),
            const SizedBox(height: 8),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create loan'),
            ),
          ],
        ),
      ),
    );
  }
}
