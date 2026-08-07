import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../providers/account_form_controller.dart';
import '../providers/finance_providers.dart';
import '../widgets/account_type_selector.dart';
import '../widgets/color_theme_picker.dart';

final Uuid _uuid = Uuid();

/// Create/edit form for an [Account]. When [accountId] is provided the
/// screen loads that account and edits it in place; otherwise it creates
/// a new one.
class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.accountId});

  final String? accountId;

  bool get isEditing => accountId != null;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  final _interestRateController = TextEditingController();
  final _notesController = TextEditingController();

  AccountType _type = AccountType.bank;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  Account? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _openingBalanceController.dispose();
    _interestRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Account account) {
    _original = account;
    _nameController.text = account.name;
    _bankNameController.text = account.bankName ?? '';
    _accountNumberController.text = account.accountNumber ?? '';
    _openingBalanceController.text = account.openingBalance.toStringAsFixed(2);
    _interestRateController.text = account.interestRate?.toStringAsFixed(2) ?? '';
    _notesController.text = account.notes ?? '';
    _type = account.type;
    _colorValue = account.colorValue;
    _prefilled = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final double openingBalance = double.tryParse(_openingBalanceController.text) ?? 0;
    final double? interestRate = _interestRateController.text.trim().isEmpty
        ? null
        : double.tryParse(_interestRateController.text);

    final Account account = Account(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      // A brand-new account starts with current == opening balance; editing
      // preserves whatever current balance transactions have since produced.
      currentBalance: _original?.currentBalance ?? openingBalance,
      openingBalance: openingBalance,
      colorValue: _colorValue,
      bankName: _bankNameController.text.trim().isEmpty
          ? null
          : _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty
          ? null
          : _accountNumberController.text.trim(),
      interestRate: interestRate,
      iconCodePoint: _original?.iconCodePoint,
      backgroundImagePath: _original?.backgroundImagePath,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isArchived: _original?.isArchived ?? false,
      sortOrder: _original?.sortOrder ?? 0,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(accountFormControllerProvider.notifier)
        .save(account, isEditing: widget.isEditing);

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
      final AsyncValue<Account?> accountAsync =
          ref.watch(accountByIdProvider(widget.accountId!));
      return accountAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit account')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit account')),
          body: Center(child: Text('Could not load account: $error')),
        ),
        data: (Account? account) {
          if (account == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit account')),
              body: const Center(child: Text('Account not found.')),
            );
          }
          _prefillFrom(account);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(accountFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit account' : 'New account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            AppTextField(
              label: 'Account name',
              controller: _nameController,
              prefixIcon: Icons.badge_outlined,
              validator: (value) => Validators.required(value, field: 'Account name'),
            ),
            const SizedBox(height: 16),
            Text('Account type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            AccountTypeSelector(
              selected: _type,
              onChanged: (type) => setState(() => _type = type),
            ),
            const SizedBox(height: 20),
            Text('Color theme', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ColorThemePicker(
              selectedColorValue: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Opening balance',
              controller: _openingBalanceController,
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) =>
                  Validators.nonNegativeNumber(value, field: 'Opening balance'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Bank / provider name (optional)',
              controller: _bankNameController,
              prefixIcon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Account number (optional)',
              controller: _accountNumberController,
              prefixIcon: Icons.numbers_rounded,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Interest rate % (optional)',
              controller: _interestRateController,
              prefixIcon: Icons.percent_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) =>
                  Validators.optionalPercentage(value, field: 'Interest rate'),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
