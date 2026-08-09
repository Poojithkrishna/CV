import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/providers/app_lock_provider.dart';
import 'core/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Built up-front (rather than inside a ProviderScope) so the
  // notification plugin finishes initializing, and the App Lock
  // preference finishes loading, before any screen — or `AppLockGate`'s
  // very first frame — can run without them.
  final ProviderContainer container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();
  await container.read(appLockEnabledProvider.notifier).loadInitial();

  runApp(UncontrolledProviderScope(container: container, child: const LifeOsApp()));
}
