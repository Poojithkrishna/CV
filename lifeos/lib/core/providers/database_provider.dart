import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// App-wide singleton database connection. Kept alive for the lifetime of
/// the app — every feature repository reads its DAO off of this.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
