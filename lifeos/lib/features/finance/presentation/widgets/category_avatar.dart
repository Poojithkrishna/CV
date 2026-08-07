import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import 'category_icons.dart';

/// Small colored circle + icon representing a category, reused in the
/// categories list, the category picker and transaction rows.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 40});

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(category.colorValue);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withOpacity(0.18),
      child: Icon(CategoryIcons.resolve(category.iconKey), color: color, size: size * 0.5),
    );
  }
}
