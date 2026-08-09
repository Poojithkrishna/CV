import 'package:flutter/material.dart';

enum MealType {
  breakfast('Breakfast', Icons.free_breakfast_outlined),
  lunch('Lunch', Icons.lunch_dining_outlined),
  dinner('Dinner', Icons.dinner_dining_outlined),
  snack('Snack', Icons.cookie_outlined);

  const MealType(this.label, this.icon);

  final String label;
  final IconData icon;
}
