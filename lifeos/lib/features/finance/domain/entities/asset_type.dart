import 'package:flutter/material.dart';

enum AssetType {
  realEstate('Real Estate', Icons.home_work_outlined),
  vehicle('Vehicle', Icons.directions_car_outlined),
  jewelry('Jewelry', Icons.diamond_outlined),
  electronics('Electronics', Icons.devices_outlined),
  collectible('Collectible', Icons.category_outlined),
  other('Other', Icons.inventory_2_outlined);

  const AssetType(this.label, this.icon);

  final String label;
  final IconData icon;
}
