import 'package:flutter/material.dart';

import '../../domain/entities/food_item.dart';

class FoodItemTile extends StatelessWidget {
  const FoodItemTile({super.key, required this.item, this.onTap, this.trailing});

  final FoodItem item;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(item.name),
        subtitle: Text(
          '${item.caloriesPerServing.toStringAsFixed(0)} kcal · '
          'P ${item.proteinG.toStringAsFixed(0)}g · '
          'C ${item.carbsG.toStringAsFixed(0)}g · '
          'F ${item.fatG.toStringAsFixed(0)}g'
          ' · per ${item.servingLabel}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
