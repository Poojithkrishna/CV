import 'package:drift/drift.dart';

import 'app_database.dart';

/// Starter exercise library seeded the first time the database is
/// created, covering the major muscle groups and equipment types so a
/// workout plan can be built immediately. Fixed ids for stability across
/// reinstalls; users can add, edit or archive any of them freely.
List<ExercisesCompanion> buildDefaultExerciseSeed(DateTime now) {
  ExercisesCompanion exercise({
    required String id,
    required String name,
    required String muscleGroup,
    required String equipment,
  }) {
    return ExercisesCompanion.insert(
      id: id,
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      isCustom: const Value(false),
      createdAt: now,
      updatedAt: now,
    );
  }

  return [
    exercise(id: 'seed-ex-bench-press', name: 'Barbell Bench Press', muscleGroup: 'chest', equipment: 'barbell'),
    exercise(id: 'seed-ex-incline-db-press', name: 'Incline Dumbbell Press', muscleGroup: 'chest', equipment: 'dumbbell'),
    exercise(id: 'seed-ex-pushup', name: 'Push-Up', muscleGroup: 'chest', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-deadlift', name: 'Deadlift', muscleGroup: 'back', equipment: 'barbell'),
    exercise(id: 'seed-ex-barbell-row', name: 'Barbell Row', muscleGroup: 'back', equipment: 'barbell'),
    exercise(id: 'seed-ex-pullup', name: 'Pull-Up', muscleGroup: 'back', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-lat-pulldown', name: 'Lat Pulldown', muscleGroup: 'back', equipment: 'machine'),
    exercise(id: 'seed-ex-ohp', name: 'Overhead Press', muscleGroup: 'shoulders', equipment: 'barbell'),
    exercise(id: 'seed-ex-lateral-raise', name: 'Lateral Raise', muscleGroup: 'shoulders', equipment: 'dumbbell'),
    exercise(id: 'seed-ex-bicep-curl', name: 'Bicep Curl', muscleGroup: 'biceps', equipment: 'dumbbell'),
    exercise(id: 'seed-ex-hammer-curl', name: 'Hammer Curl', muscleGroup: 'biceps', equipment: 'dumbbell'),
    exercise(id: 'seed-ex-tricep-dip', name: 'Tricep Dip', muscleGroup: 'triceps', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-tricep-pushdown', name: 'Tricep Pushdown', muscleGroup: 'triceps', equipment: 'machine'),
    exercise(id: 'seed-ex-squat', name: 'Barbell Squat', muscleGroup: 'legs', equipment: 'barbell'),
    exercise(id: 'seed-ex-leg-press', name: 'Leg Press', muscleGroup: 'legs', equipment: 'machine'),
    exercise(id: 'seed-ex-lunge', name: 'Lunge', muscleGroup: 'legs', equipment: 'dumbbell'),
    exercise(id: 'seed-ex-bodyweight-squat', name: 'Bodyweight Squat', muscleGroup: 'legs', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-hip-thrust', name: 'Hip Thrust', muscleGroup: 'glutes', equipment: 'barbell'),
    exercise(id: 'seed-ex-plank', name: 'Plank', muscleGroup: 'core', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-situp', name: 'Sit-Up', muscleGroup: 'core', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-resistance-row', name: 'Resistance Band Row', muscleGroup: 'back', equipment: 'resistanceBand'),
    exercise(id: 'seed-ex-band-pull-apart', name: 'Band Pull-Apart', muscleGroup: 'shoulders', equipment: 'resistanceBand'),
    exercise(id: 'seed-ex-running', name: 'Running', muscleGroup: 'cardio', equipment: 'cardio'),
    exercise(id: 'seed-ex-cycling', name: 'Cycling', muscleGroup: 'cardio', equipment: 'cardio'),
    exercise(id: 'seed-ex-jump-rope', name: 'Jump Rope', muscleGroup: 'cardio', equipment: 'bodyweight'),
    exercise(id: 'seed-ex-burpee', name: 'Burpee', muscleGroup: 'fullBody', equipment: 'bodyweight'),
  ];
}
