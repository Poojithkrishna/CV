import 'package:flutter/foundation.dart';

@immutable
class WaterEntry {
  const WaterEntry({
    required this.id,
    required this.date,
    required this.updatedAt,
    this.amountMl = 0,
  });

  final String id;
  final DateTime date;
  final int amountMl;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) => other is WaterEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
