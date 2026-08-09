import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../data/daos/cardio_sessions_dao.dart';
import '../../data/repositories/cardio_session_repository_impl.dart';
import '../../domain/entities/cardio_session.dart';
import '../../domain/repositories/cardio_session_repository.dart';
import '../../domain/usecases/delete_cardio_session.dart';
import '../../domain/usecases/log_cardio_session.dart';
import '../../domain/usecases/update_cardio_session.dart';

final Provider<CardioSessionsDao> cardioSessionsDaoProvider = Provider<CardioSessionsDao>((ref) {
  return CardioSessionsDao(ref.watch(appDatabaseProvider));
});

final Provider<CardioSessionRepository> cardioSessionRepositoryProvider =
    Provider<CardioSessionRepository>((ref) {
  return CardioSessionRepositoryImpl(ref.watch(cardioSessionsDaoProvider));
});

final Provider<LogCardioSession> logCardioSessionUseCaseProvider = Provider(
  (ref) => LogCardioSession(ref.watch(cardioSessionRepositoryProvider)),
);
final Provider<UpdateCardioSession> updateCardioSessionUseCaseProvider = Provider(
  (ref) => UpdateCardioSession(ref.watch(cardioSessionRepositoryProvider)),
);
final Provider<DeleteCardioSession> deleteCardioSessionUseCaseProvider = Provider(
  (ref) => DeleteCardioSession(ref.watch(cardioSessionRepositoryProvider)),
);

final StreamProvider<List<CardioSession>> allCardioSessionsProvider =
    StreamProvider<List<CardioSession>>((ref) {
  return ref.watch(cardioSessionRepositoryProvider).watchAllSessions();
});

final StreamProviderFamily<CardioSession?, String> cardioSessionByIdProvider =
    StreamProvider.family<CardioSession?, String>((ref, id) {
  return ref.watch(cardioSessionRepositoryProvider).watchSession(id);
});
