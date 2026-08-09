import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_gradients.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/color_theme_picker.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/entities/investment.dart';
import '../../domain/entities/investment_type.dart';
import '../providers/investment_form_controller.dart';
import '../providers/investment_providers.dart';

final Uuid _uuid = Uuid();

class InvestmentFormScreen extends ConsumerStatefulWidget {
  const InvestmentFormScreen({super.key, this.investmentId});

  final String? investmentId;

  bool get isEditing => investmentId != null;

  @override
  ConsumerState<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends ConsumerState<InvestmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _investedController = TextEditingController(text: '0');
  final _currentValueController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  InvestmentType _type = InvestmentType.stocks;
  DateTime? _purchaseDate;
  int _colorValue = AppGradients.palette.first.colors.first.value;
  Investment? _original;
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _prefillFrom(Investment investment) {
    _original = investment;
    _nameController.text = investment.name;
    _investedController.text = investment.investedAmount.toStringAsFixed(2);
    _currentValueController.text = investment.currentValue.toStringAsFixed(2);
    _notesController.text = investment.notes ?? '';
    _type = investment.type;
    _purchaseDate = investment.purchaseDate;
    _colorValue = investment.colorValue;
    _prefilled = true;
  }

  Future<void> _pickPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime now = DateTime.now();
    final Investment investment = Investment(
      id: _original?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      investedAmount: double.tryParse(_investedController.text) ?? 0,
      currentValue: double.tryParse(_currentValueController.text) ?? 0,
      purchaseDate: _purchaseDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      colorValue: _colorValue,
      isArchived: _original?.isArchived ?? false,
      createdAt: _original?.createdAt ?? now,
      updatedAt: now,
    );

    final result = await ref
        .read(investmentFormControllerProvider.notifier)
        .save(investment, isEditing: widget.isEditing);

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
      title: 'Delete investment?',
      message: 'This permanently removes it from your portfolio.',
    );
    if (!confirmed) return;
    final result = await ref.read(deleteInvestmentUseCaseProvider).call(id);
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
      final AsyncValue<Investment?> investmentAsync =
          ref.watch(investmentByIdProvider(widget.investmentId!));
      return investmentAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit investment')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit investment')),
          body: Center(child: Text('Could not load investment: $error')),
        ),
        data: (Investment? investment) {
          if (investment == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit investment')),
              body: const Center(child: Text('Investment not found.')),
            );
          }
          _prefillFrom(investment);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final AsyncValue<void> formState = ref.watch(investmentFormControllerProvider);
    final bool isSaving = formState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit investment' : 'New investment'),
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
            AppTextField(
              label: 'Name',
              controller: _nameController,
              prefixIcon: Icons.trending_up_rounded,
              hint: 'e.g. Nifty 50 Index Fund',
              validator: (value) => Validators.required(value, field: 'Name'),
            ),
            const SizedBox(height: 16),
            Text('Type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final InvestmentType type in InvestmentType.values)
                  ChoiceChip(
                    avatar: Icon(type.icon, size: 16),
                    label: Text(type.label),
                    selected: type == _type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount invested',
              controller: _investedController,
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Invested amount'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Current value',
              controller: _currentValueController,
              prefixIcon: Icons.account_balance_wallet_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: decimalInputFormatters,
              validator: (value) => Validators.nonNegativeNumber(value, field: 'Current value'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(_purchaseDate != null
                  ? 'Purchased ${AppFormatters.shortDate(_purchaseDate!)}'
                  : 'No purchase date'),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickPurchaseDate,
            ),
            const SizedBox(height: 8),
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
                  : Text(widget.isEditing ? 'Save changes' : 'Create investment'),
            ),
          ],
        ),
      ),
    );
  }
}
