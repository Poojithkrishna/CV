import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_lock_provider.dart';
import '../core/widgets/app_lock_screen.dart';

/// Wraps the whole app (via `MaterialApp.router`'s `builder`). Shows
/// [child] once App Lock is off, or the current session has already
/// unlocked; otherwise shows [AppLockScreen]. Re-locks the session the
/// moment the app is backgrounded, so switching away and back always
/// re-prompts — matching how every other app-lock feature behaves.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool? enabled = ref.read(appLockEnabledProvider);
    if (enabled != true) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      ref.read(appLockSessionProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool? enabled = ref.watch(appLockEnabledProvider);

    // Defensive only — `loadInitial()` is awaited in `main()` before
    // `runApp`, so this resolves before the first real frame in
    // practice. Blank rather than the real app either way.
    if (enabled == null) {
      return const ColoredBox(color: Colors.black);
    }
    if (!enabled) return widget.child;

    final bool unlocked = ref.watch(appLockSessionProvider);
    return unlocked ? widget.child : const AppLockScreen();
  }
}
