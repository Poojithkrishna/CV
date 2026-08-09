import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import 'home_widget_deep_link.dart';

/// Cold-start case: the app process itself was launched by a widget
/// tap. Must be awaited before `runApp` so the very first frame already
/// reflects the target screen instead of flashing the dashboard first
/// — `GoRouter.go` can be called before the router is ever attached to
/// a `MaterialApp.router`, it just updates which location the first
/// build reads back.
Future<void> handleInitialWidgetLaunch(GoRouter router) async {
  final Uri? uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  final String? route = routeForWidgetTap(uri);
  if (route != null) router.go(route);
}

/// Warm case: the app process was already alive (foreground or
/// background) when a widget section was tapped again.
void listenForWidgetTaps(GoRouter router) {
  HomeWidget.widgetClicked.listen((Uri? uri) {
    final String? route = routeForWidgetTap(uri);
    if (route != null) router.go(route);
  });
}
