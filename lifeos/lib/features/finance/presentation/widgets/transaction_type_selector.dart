import 'package:flutter/material.dart';

import '../../domain/entities/transaction_type.dart';

class TransactionTypeSelector extends StatelessWidget {
  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: [
        for (final TransactionType type in TransactionType.values)
          ButtonSegment(
            value: type,
            label: Text(type.label),
            icon: Icon(type.icon, size: 18),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
