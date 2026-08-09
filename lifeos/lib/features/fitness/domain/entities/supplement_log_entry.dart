import 'package:flutter/foundation.dart';

/// Whether a `Supplement` was taken on a given day — one entry per
/// supplement per day, upserted by `SupplementsDao.toggleTaken`.
@immutable
class SupplementLogEntry {
  const SupplementLogEntry({
    required this.id,
    required this.supplementId,
    required this.date,
    required this.createdAt,
    this.taken = true,
  });

  final String id;
  final String supplementId;
  final DateTime date;
  final bool taken;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) => other is SupplementLogEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
