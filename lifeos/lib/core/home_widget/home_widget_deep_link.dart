/// Maps a widget-tap URI to the in-app route it should open. The native
/// `LifeOsWidgetProvider` attaches a distinct `lifeos://widget/<section>`
/// URI to each tappable section's launch intent (see the Kotlin side),
/// so this just reads that one path segment back out — kept pure and
/// separate from the actual plugin/router calls in
/// `home_widget_deep_link_service.dart`, the same split as
/// `buildHomeWidgetData` versus `HomeWidgetSyncService`.
///
/// Returns `null` for anything unrecognized (a stale build's URI, a
/// malformed value, or simply no widget tap at all) so an absent or
/// unknown URI never forces a navigation.
String? routeForWidgetTap(Uri? uri) {
  if (uri == null || uri.scheme != 'lifeos' || uri.host != 'widget') return null;
  if (uri.pathSegments.isEmpty) return null;

  switch (uri.pathSegments.first) {
    case 'dashboard':
      return '/dashboard';
    case 'gamification':
      return '/gamification';
    case 'finance':
      return '/finance';
    case 'habits':
      return '/habits';
    case 'calendar':
      return '/calendar';
    default:
      return null;
  }
}
