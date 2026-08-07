import 'package:flutter/material.dart';

/// Curated set of icons a category can use, keyed by the string stored in
/// [Category.iconKey]. Kept as a fixed catalog (rather than a free-form
/// icon picker) so seed data and user picks both resolve through the same
/// small, reviewable map instead of raw font code points.
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> catalog = {
    'salary': Icons.payments_rounded,
    'freelance': Icons.laptop_mac_rounded,
    'gift': Icons.card_giftcard_rounded,
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_car_filled_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'bills': Icons.receipt_long_rounded,
    'entertainment': Icons.movie_rounded,
    'health': Icons.favorite_rounded,
    'education': Icons.school_rounded,
    'home': Icons.home_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'fitness': Icons.fitness_center_rounded,
    'investment': Icons.trending_up_rounded,
    'pets': Icons.pets_rounded,
    'other': Icons.category_rounded,
  };

  static IconData resolve(String? key) => catalog[key] ?? Icons.category_rounded;
}
