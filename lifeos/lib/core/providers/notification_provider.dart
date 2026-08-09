import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifications/notification_service.dart';

/// App-wide singleton notification service. Initialized once in `main`
/// before `runApp`, via a pre-built `ProviderContainer` — see
/// `main.dart`.
final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
