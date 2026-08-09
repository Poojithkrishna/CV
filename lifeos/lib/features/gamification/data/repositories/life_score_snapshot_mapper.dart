import '../../../../core/database/app_database.dart';
import '../../domain/entities/life_score_snapshot.dart';
import '../../domain/entities/rank.dart';

extension LifeScoreSnapshotRowMapper on LifeScoreSnapshotRow {
  LifeScoreSnapshot toDomain() {
    return LifeScoreSnapshot(
      id: id,
      date: date,
      lifeScore: lifeScore,
      xp: xp,
      rank: Rank.values[rankIndex],
    );
  }
}
