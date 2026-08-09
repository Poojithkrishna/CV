import 'package:flutter/foundation.dart';

import 'measurement_type.dart';

@immutable
class MeasurementEntry {
  const MeasurementEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.valueCm,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  final String id;
  final MeasurementType type;
  final DateTime date;
  final double valueCm;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) => other is MeasurementEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
