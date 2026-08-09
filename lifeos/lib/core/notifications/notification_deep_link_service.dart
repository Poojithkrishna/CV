import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'notification_deep_link.dart';
import 'notification_service.dart';

/// Cold-start case: the app process itself was launched by tapping a
/// notification. Must be awaited before `runApp` — same reasoning as
/// the widget's `handleInitialWidgetLaunch` — so the first frame
/// already reflects the target screen instead of flashing the
/// dashboard first. Action-button launches (Mark done, Snooze) are
/// deliberately not routed here — see `notification_action_handler.dart`,
/// which handles those and leaves plain taps alone.
Future<void> handleInitialNotificationLaunch(NotificationService service, GoRouter router) async {
  final NotificationResponse? response = await service.initialLaunchResponse();
  if (response == null) return;
  if (response.notificationResponseType == NotificationResponseType.selectedNotificationAction) return;

  final String? route = routeForNotificationPayload(response.payload);
  if (route != null) router.go(route);
}

/// Warm case: the app process was already alive (foreground or
/// background) when a notification was tapped.
void listenForNotificationTaps(NotificationService service, GoRouter router) {
  service.onNotificationResponse.listen((NotificationResponse response) {
    if (response.notificationResponseType == NotificationResponseType.selectedNotificationAction) return;

    final String? route = routeForNotificationPayload(response.payload);
    if (route != null) router.go(route);
  });
}
