import '../../../../core/database/app_database.dart';
import '../../domain/entities/supplement_log_entry.dart';

extension SupplementLogEntryRowMapper on SupplementLogEntryRow {
  SupplementLogEntry toDomain() {
    return SupplementLogEntry(
      id: id,
      supplementId: supplementId,
      date: date,
      taken: taken,
      createdAt: createdAt,
    );
  }
}
