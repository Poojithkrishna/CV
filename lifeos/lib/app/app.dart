import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/theme_mode_provider.dart';
import 'app_lock_gate.dart';
import 'router/app_router.dart';
import 'theme/ambient_background.dart';
import 'theme/app_theme.dart';

class DemonOriginApp extends ConsumerWidget {
  const DemonOriginApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Demon Origin',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: appRouter,
      builder: (context, child) {
        // Mounted once, outside the router's Navigator, so it's behind
        // every screen the app ever pushes without any per-screen wiring
        // — see AmbientBackground's doc comment.
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Stack(
          children: [
            if (isDark) const Positioned.fill(child: AmbientBackground()),
            AppLockGate(child: child!),
          ],
        );
      },
    );
  }
}
