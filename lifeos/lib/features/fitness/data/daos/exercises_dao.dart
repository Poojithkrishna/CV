import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../tables/exercises_table.dart';

part 'exercises_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExercisesDao extends DatabaseAccessor<AppDatabase> with _$ExercisesDaoMixin {
  ExercisesDao(super.db);

  Stream<List<ExerciseRow>> watchActiveExercises({String? muscleGroup}) {
    final query = select(exercises)..where((tbl) => tbl.isArchived.equals(false));
    if (muscleGroup != null) {
      query.where((tbl) => tbl.muscleGroup.equals(muscleGroup));
    }
    query.orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    return query.watch();
  }

  Stream<ExerciseRow?> watchExercise(String id) {
    return (select(exercises)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<ExerciseRow?> getExercise(String id) {
    return (select(exercises)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertExercise(ExercisesCompanion entry) {
    return into(exercises).insert(entry);
  }

  Future<bool> updateExercise(ExercisesCompanion entry) {
    return update(exercises).replace(entry);
  }

  Future<int> deleteExercise(String id) {
    return (delete(exercises)..where((tbl) => tbl.id.equals(id))).go();
  }
}
