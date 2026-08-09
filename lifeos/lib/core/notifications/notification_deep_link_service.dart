import 'package:go_router/go_router.dart';

import 'notification_deep_link.dart';
import 'notification_service.dart';

/// Cold-start case: the app process itself was launched by tapping a
/// notification. Must be awaited before `runApp` — same reasoning as
/// the widget's `handleInitialWidgetLaunch` — so the first frame
/// already reflects the target screen instead of flashing the
/// dashboard first.
Future<void> handleInitialNotificationLaunch(NotificationService service, GoRouter router) async {
  final String? payload = await service.initialLaunchPayload();
  final String? route = routeForNotificationPayload(payload);
  if (route != null) router.go(route);
}

/// Warm case: the app process was already alive (foreground or
/// background) when a notification was tapped.
void listenForNotificationTaps(NotificationService service, GoRouter router) {
  service.onNotificationTapped.listen((String? payload) {
    final String? route = routeForNotificationPayload(payload);
    if (route != null) router.go(route);
  });
}
