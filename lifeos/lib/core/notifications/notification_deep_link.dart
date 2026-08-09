/// The reminder types every notification payload carries — shared
/// between payload construction (`buildNotificationPayload`, called
/// from each `syncXReminder`) and everything that reads it back
/// (`routeForNotificationPayload`, `notification_actions.dart`'s
/// `actionsFor`), so the two sides can never drift out of sync the way
/// hand-typed string literals could.
const String notificationTypeLoan = 'loan';
const String notificationTypeRecurringPayment = 'recurring-payment';
const String notificationTypeTask = 'task';
const String notificationTypeEvent = 'event';

/// A scheduled notification's payload, decoded. Carries the title/body
/// alongside type/id so a Snooze action can reschedule the exact same
/// content without re-fetching the entity from the database — see
/// `notification_action_handler.dart`.
class NotificationContent {
  const NotificationContent({
    required this.type,
    required this.id,
    required this.title,
    required this.body,
  });

  final String type;
  final String id;
  final String title;
  final String body;
}

/// Builds the payload every `syncXReminder` attaches to its scheduled
/// notification: a `lifeos://notification/<type>/<id>` URI carrying
/// title/body as query parameters. Kept as one shared builder (rather
/// than each reminder file hand-interpolating its own string) so
/// construction and parsing can never drift apart.
Uri buildNotificationPayload({
  required String type,
  required String id,
  required String title,
  required String body,
}) {
  return Uri(
    scheme: 'lifeos',
    host: 'notification',
    pathSegments: [type, id],
    queryParameters: {'title': title, 'body': body},
  );
}

/// The inverse of [buildNotificationPayload]. Returns `null` for
/// anything unparseable (a stale build's payload, a malformed value, or
/// no payload at all) so a broken payload never crashes a tap handler.
NotificationContent? notificationContentFromPayload(String? payload) {
  if (payload == null) return null;
  final Uri? uri = Uri.tryParse(payload);
  if (uri == null || uri.scheme != 'lifeos' || uri.host != 'notification') return null;
  if (uri.pathSegments.length < 2) return null;

  return NotificationContent(
    type: uri.pathSegments[0],
    id: uri.pathSegments[1],
    title: uri.queryParameters['title'] ?? '',
    body: uri.queryParameters['body'] ?? '',
  );
}

/// Maps a scheduled notification's payload to the in-app route a plain
/// tap (not an action button) should open. Returns `null` for anything
/// unrecognized so a tap never forces a navigation it can't confidently
/// resolve.
String? routeForNotificationPayload(String? payload) {
  final NotificationContent? content = notificationContentFromPayload(payload);
  if (content == null) return null;

  switch (content.type) {
    case notificationTypeLoan:
      return '/finance/loans/${content.id}';
    case notificationTypeRecurringPayment:
      return '/finance/recurring-payments/${content.id}';
    case notificationTypeTask:
      return '/calendar/tasks/${content.id}/edit';
    case notificationTypeEvent:
      return '/calendar/events/${content.id}/edit';
    default:
      return null;
  }
}
