import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_widget/home_widget_sync_service.dart';

final Provider<HomeWidgetSyncService> homeWidgetSyncServiceProvider =
    Provider<HomeWidgetSyncService>((ref) => HomeWidgetSyncService());
