import 'package:home_widget/home_widget.dart';

/// Thin wrapper around the `home_widget` plugin — writes each value
/// into the shared storage the native `LifeOsWidgetProvider` reads
/// from, then asks Android to redraw it.
class HomeWidgetSyncService {
  static const String _androidProviderName = 'LifeOsWidgetProvider';

  Future<void> push(Map<String, String> data) async {
    for (final MapEntry<String, String> entry in data.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
