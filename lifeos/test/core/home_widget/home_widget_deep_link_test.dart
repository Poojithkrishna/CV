import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/home_widget/home_widget_deep_link.dart';

void main() {
  group('routeForWidgetTap', () {
    test('maps each known section to its route', () {
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/dashboard')), '/dashboard');
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/gamification')), '/gamification');
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/finance')), '/finance');
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/habits')), '/habits');
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/calendar')), '/calendar');
    });

    test('returns null for a null uri', () {
      expect(routeForWidgetTap(null), isNull);
    });

    test('returns null for an unrecognized section', () {
      expect(routeForWidgetTap(Uri.parse('lifeos://widget/nonexistent')), isNull);
    });

    test('returns null for a uri with no path segments', () {
      expect(routeForWidgetTap(Uri.parse('lifeos://widget')), isNull);
    });

    test('returns null for a mismatched scheme', () {
      expect(routeForWidgetTap(Uri.parse('https://widget/gamification')), isNull);
    });

    test('returns null for a mismatched host', () {
      expect(routeForWidgetTap(Uri.parse('lifeos://not-widget/gamification')), isNull);
    });
  });
}
