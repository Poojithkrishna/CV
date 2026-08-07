import 'package:flutter/material.dart';

import 'category_icons.dart';

/// Grid picker over [CategoryIcons.catalog], used in the category form.
class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selectedKey,
    required this.onChanged,
    required this.color,
  });

  final String? selectedKey;
  final ValueChanged<String> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final MapEntry<String, IconData> entry in CategoryIcons.catalog.entries)
          GestureDetector(
            onTap: () => onChanged(entry.key),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: entry.key == selectedKey
                    ? color
                    : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                entry.value,
                size: 20,
                color: entry.key == selectedKey ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
