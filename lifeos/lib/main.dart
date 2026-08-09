import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Built up-front (rather than inside a ProviderScope) so the
  // notification plugin finishes initializing before any screen can try
  // to schedule a reminder through it.
  final ProviderContainer container = ProviderContainer();
  await container.read(notificationServiceProvider).initialize();

  runApp(UncontrolledProviderScope(container: container, child: const LifeOsApp()));
}
