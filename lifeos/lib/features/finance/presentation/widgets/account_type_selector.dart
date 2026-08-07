import 'package:flutter/material.dart';

import '../../domain/entities/account_type.dart';

/// Horizontal chip selector for [AccountType], used in the account form.
class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AccountType selected;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final AccountType type in AccountType.values)
          ChoiceChip(
            label: Text(type.label),
            avatar: Icon(type.defaultIcon, size: 18),
            selected: type == selected,
            onSelected: (_) => onChanged(type),
          ),
      ],
    );
  }
}
