import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/logged_set.dart';

extension LoggedSetRowMapper on LoggedSetRow {
  LoggedSet toDomain() {
    return LoggedSet(
      id: id,
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      isWarmup: isWarmup,
      isPr: isPr,
      completedAt: completedAt,
    );
  }
}

extension LoggedSetEntityMapper on LoggedSet {
  LoggedSetsCompanion toCompanion() {
    return LoggedSetsCompanion.insert(
      id: id,
      sessionId: sessionId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weight: weight,
      isWarmup: Value(isWarmup),
      isPr: Value(isPr),
      completedAt: completedAt,
    );
  }
}
