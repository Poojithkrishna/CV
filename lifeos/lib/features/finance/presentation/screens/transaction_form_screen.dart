import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/category_type.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/entities/transaction_type.dart';
import '../providers/transaction_form_controller.dart';
import '../providers/transaction_providers.dart';
import '../widgets/account_picker_field.dart';
import '../widgets/category_picker_field.dart';
import '../widgets/transaction_type_selector.dart';

final Uuid _uuid = Uuid();

/// Create/edit form for a [TransactionEntry]. [initialAccountId]
/// pre-selects an account when arriving from that account's own
/// transaction list (ignored once editing an existing transaction, whose
/// own account takes precedence).
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transactionId, this.initialAccountId});

  final String? transactionId;
  final String? initialAccountId;

  bool get isEditing => transactionId != null;

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _accountId;
  String? _transferAccountId;
  String? _categoryId;
  DateTime _date = DateTime.now();

  TransactionEntry? _original;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _prefillFrom(TransactionEntry entry) {
    _original = entry;
    _type = entry.type;
    _accountId = entry.accountId;
    _transferAccountId = entry.transferAccountId;
    _categoryId = entry.categoryId;
    _date = entry.date;
    _amountController.text = entry.amount.toStringAsFixed(2);
    _noteController.text = entry.note ?? '';
    _prefilled = true;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountId == null) return;

    final DateTime now = DateTime.now();
    final double amount = double.tryParse(_amountController.text) ?? 0;
    final bool isTransfer = _type == TransactionType.transfer;

    final TransactionEntry entry = TransactionEntry(
      id: _original?.id ?? _uuid.v4(),
      accountId: _accountId!,
      type: _type,
      amount: amount,
      date: _date,
      categoryId: isTransfer ? null : _categoryId,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      transferAccountId: isTransfer ? _transferAccountId : null,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(transactionFormControllerProvider.notifier)
        .save(entry, isEditing: widget.isEditing);

    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.of(context).pop(),
      err: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
    );
  }

  Future<void> _delete() async {
    final String? id = _original?.id;
    if (id == null) return;

    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete transaction?',
      message: 'This reverses its effect on the account balance and cannot be undone.',
    );
    if (!confirmed) return;

    final result = await ref.read(deleteTransactionUseCaseProvider).call(id);
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
      final AsyncValue<TransactionEntry?> entryAsync =
          ref.watch(transactionByIdProvider(widget.transactionId!));
      return entryAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit transaction')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit transaction')),
          body: Center(child: Text('Could not load transaction: $error')),
        ),
        data: (TransactionEntry? entry) {
          if (entry == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit transaction')),
              body: const Center(child: Text('Transaction not found.')),
            );
          }
          _prefillFrom(entry);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(transactionFormControllerProvider);
    final bool isSaving = formState.isLoading;
    final bool isTransfer = _type == TransactionType.transfer;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit transaction' : 'New transaction'),
        actions: [
          if (widget.isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Center(
              child: TransactionTypeSelector(
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  if (type != TransactionType.transfer) _transferAccountId = null;
                }),
              ),
            ),
            const SizedBox(height: 20),
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
            AccountPickerField(
              label: isTransfer ? 'From account' : 'Account',
              selectedAccountId: _accountId,
              onChanged: (value) => setState(() => _accountId = value),
            ),
            if (isTransfer) ...[
              const SizedBox(height: 16),
              AccountPickerField(
                label: 'To account',
                selectedAccountId: _transferAccountId,
                excludeAccountId: _accountId,
                onChanged: (value) => setState(() => _transferAccountId = value),
              ),
            ] else ...[
              const SizedBox(height: 16),
              CategoryPickerField(
                type: _type == TransactionType.income ? CategoryType.income : CategoryType.expense,
                selectedCategoryId: _categoryId,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(AppFormatters.shortDate(_date)),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Note (optional)',
              controller: _noteController,
              prefixIcon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: isSaving || _accountId == null ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Save changes' : 'Add transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
