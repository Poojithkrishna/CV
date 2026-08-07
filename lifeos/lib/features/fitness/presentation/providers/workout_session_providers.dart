import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/workout_sessions_dao.dart';
import '../../data/repositories/workout_session_repository_impl.dart';
import '../../domain/entities/logged_set.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/workout_session_repository.dart';
import '../../domain/usecases/delete_logged_set.dart';
import '../../domain/usecases/delete_workout_session.dart';
import '../../domain/usecases/end_workout_session.dart';
import '../../domain/usecases/log_set.dart';
import '../../domain/usecases/start_workout_session.dart';

final Provider<WorkoutSessionsDao> workoutSessionsDaoProvider = Provider<WorkoutSessionsDao>((ref) {
  return WorkoutSessionsDao(ref.watch(appDatabaseProvider));
});

final Provider<WorkoutSessionRepository> workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepositoryImpl(ref.watch(workoutSessionsDaoProvider));
});

final Provider<StartWorkoutSession> startWorkoutSessionUseCaseProvider = Provider(
  (ref) => StartWorkoutSession(ref.watch(workoutSessionRepositoryProvider)),
);
final Provider<EndWorkoutSession> endWorkoutSessionUseCaseProvider = Provider(
  (ref) => EndWorkoutSession(ref.watch(workoutSessionRepositoryProvider)),
);
final Provider<DeleteWorkoutSession> deleteWorkoutSessionUseCaseProvider = Provider(
  (ref) => DeleteWorkoutSession(ref.watch(workoutSessionRepositoryProvider)),
);
final Provider<LogSet> logSetUseCaseProvider = Provider(
  (ref) => LogSet(ref.watch(workoutSessionRepositoryProvider)),
);
final Provider<DeleteLoggedSet> deleteLoggedSetUseCaseProvider = Provider(
  (ref) => DeleteLoggedSet(ref.watch(workoutSessionRepositoryProvider)),
);

final StreamProviderFamily<List<WorkoutSession>, int> recentSessionsProvider =
    StreamProvider.family<List<WorkoutSession>, int>((ref, limit) {
  return ref.watch(workoutSessionRepositoryProvider).watchRecentSessions(limit: limit);
});

final StreamProviderFamily<WorkoutSession?, String> workoutSessionByIdProvider =
    StreamProvider.family<WorkoutSession?, String>((ref, id) {
  return ref.watch(workoutSessionRepositoryProvider).watchSession(id);
});

/// The workout still open (no end time), if any — lets the app resume an
/// in-progress session after being backgrounded or restarted.
final StreamProvider<WorkoutSession?> inProgressSessionProvider = StreamProvider<WorkoutSession?>((ref) {
  return ref.watch(workoutSessionRepositoryProvider).watchInProgressSession();
});

final StreamProviderFamily<List<LoggedSet>, String> setsForSessionProvider =
    StreamProvider.family<List<LoggedSet>, String>((ref, sessionId) {
  return ref.watch(workoutSessionRepositoryProvider).watchSetsForSession(sessionId);
});

/// The single most recent set logged for an exercise (across every past
/// session) — "previous performance" and the basis for a progression
/// suggestion. Invalidated manually after logging a new set for the same
/// exercise so it stays current within a live session.
final FutureProviderFamily<LoggedSet?, String> lastLoggedSetForExerciseProvider =
    FutureProvider.family<LoggedSet?, String>((ref, exerciseId) async {
  final List<LoggedSet> recent = await ref
      .watch(workoutSessionRepositoryProvider)
      .getRecentSetsForExercise(exerciseId, limit: 1);
  return recent.isEmpty ? null : recent.first;
});
