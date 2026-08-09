import '../../features/gamification/domain/entities/gamification_snapshot.dart';

/// Builds the exact key→value strings pushed to the Android home
/// screen widget, kept separate from the actual `home_widget` plugin
/// calls (in `HomeWidgetSyncService`) so this mapping is testable
/// without a platform channel — same pure-logic/thin-orchestration
/// split as the notification reminder-time functions.
///
/// Every value here is already-formatted display text reused straight
/// from the dashboard's own computed strings — no new formatting rules
/// invented just for the widget.
Map<String, String> buildHomeWidgetData({
  required GamificationSnapshot? gamificationSnapshot,
  required String netWorthValue,
  required String habitCompletionValue,
  required String scheduleSummary,
}) {
  return {
    'rank_label': gamificationSnapshot?.rank.label ?? 'Mortal',
    'xp_label': '${gamificationSnapshot?.xp ?? 0} XP',
    'net_worth': netWorthValue,
    'habit_completion': habitCompletionValue,
    'schedule_summary': scheduleSummary,
  };
}
