import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../backup/backup_service.dart';

final Provider<BackupService> backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});
