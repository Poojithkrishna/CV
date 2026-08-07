import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/account.dart';
import '../providers/finance_providers.dart';

/// Dropdown over the active accounts list, used for both the transaction
/// account and (for transfers) the destination account.
class AccountPickerField extends ConsumerWidget {
  const AccountPickerField({
    super.key,
    required this.label,
    required this.selectedAccountId,
    required this.onChanged,
    this.excludeAccountId,
    this.required = true,
  });

  final String label;
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;

  /// Hides one account from the list — used so a transfer's destination
  /// picker can't select the same account as the source.
  final String? excludeAccountId;

  /// Whether leaving this field empty should fail validation. Some
  /// callers (e.g. a recurring payment that isn't tracked against a
  /// specific account) want the field to stay optional.
  final bool required;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(activeAccountsProvider);

    return accountsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Could not load accounts: $error'),
      data: (List<Account> accounts) {
        final List<Account> options =
            accounts.where((a) => a.id != excludeAccountId).toList();

        return DropdownButtonFormField<String>(
          value: options.any((a) => a.id == selectedAccountId) ? selectedAccountId : null,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          ),
          items: [
            for (final Account account in options)
              DropdownMenuItem(value: account.id, child: Text(account.name)),
          ],
          onChanged: onChanged,
          validator: required ? (value) => value == null ? 'Choose an account' : null : null,
        );
      },
    );
  }
}
