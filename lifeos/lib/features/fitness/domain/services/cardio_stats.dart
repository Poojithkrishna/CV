import '../entities/cardio_session.dart';

/// Pure, DB-free totals shared by the Cardio list screen's summary card.
class CardioStats {
  CardioStats._();

  static double totalDurationMinutes(Iterable<CardioSession> sessions) {
    return sessions.fold<double>(0, (sum, s) => sum + s.durationMinutes);
  }

  static double totalDistanceKm(Iterable<CardioSession> sessions) {
    return sessions.fold<double>(0, (sum, s) => sum + (s.distanceKm ?? 0));
  }

  /// Sessions with a date on or after [since].
  static List<CardioSession> since(List<CardioSession> sessions, DateTime since) {
    return sessions.where((s) => !s.date.isBefore(since)).toList(growable: false);
  }
}
