/// Maps a scheduled notification's payload to the in-app route it
/// should open when tapped. Every reminder (`loan_reminders.dart`,
/// `recurring_payment_reminders.dart`, `calendar_reminders.dart`)
/// attaches a `lifeos://notification/<type>/<id>` payload when it
/// schedules — this just reads the type/id back out. Kept pure and
/// separate from the actual plugin/router calls in
/// `notification_deep_link_service.dart`, the same split as the home
/// widget's `routeForWidgetTap` versus its service.
///
/// Returns `null` for anything unrecognized (a stale build's payload,
/// a malformed value, or no payload at all) so a notification tap
/// never forces a navigation it can't confidently resolve.
String? routeForNotificationPayload(String? payload) {
  if (payload == null) return null;
  final Uri? uri = Uri.tryParse(payload);
  if (uri == null || uri.scheme != 'lifeos' || uri.host != 'notification') return null;
  if (uri.pathSegments.length < 2) return null;

  final String type = uri.pathSegments[0];
  final String id = uri.pathSegments[1];
  switch (type) {
    case 'loan':
      return '/finance/loans/$id';
    case 'recurring-payment':
      return '/finance/recurring-payments/$id';
    case 'task':
      return '/calendar/tasks/$id/edit';
    case 'event':
      return '/calendar/events/$id/edit';
    default:
      return null;
  }
}
