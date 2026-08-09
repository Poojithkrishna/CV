import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/app_lock_service.dart';

const String _prefsKey = 'lifeos.app_lock_enabled';

final Provider<AppLockService> appLockServiceProvider = Provider<AppLockService>((ref) {
  return AppLockService();
});

/// Whether App Lock is turned on, persisted across launches. Starts
/// `null` (rather than defaulting to `false` like `ThemeModeController`
/// does for its own preference) because this one is security-critical —
/// showing the app unlocked for even one frame while the real value
/// loads would defeat the whole feature. `loadInitial` is awaited in
/// `main()` before `runApp`, so in practice this is never actually
/// null by the time a widget reads it; the null case in `AppLockGate`
/// is purely a defensive fallback.
class AppLockEnabledController extends Notifier<bool?> {
  @override
  bool? build() => null;

  Future<void> loadInitial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}

final NotifierProvider<AppLockEnabledController, bool?> appLockEnabledProvider =
    NotifierProvider<AppLockEnabledController, bool?>(AppLockEnabledController.new);

/// Whether the *current* app session has passed the lock screen.
/// Deliberately never persisted — every cold start, and every return
/// from the background while App Lock is enabled, starts locked again.
class AppLockSessionController extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;
  void lock() => state = false;
}

final NotifierProvider<AppLockSessionController, bool> appLockSessionProvider =
    NotifierProvider<AppLockSessionController, bool>(AppLockSessionController.new);
