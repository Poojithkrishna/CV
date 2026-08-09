import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'lifeos.theme_mode';

/// Persisted light/dark/system theme preference. Demon Origin defaults to dark
/// mode since it's a personal, always-on-phone tool used day and night,
/// but a full light theme is supported too.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    unawaited(_load());
    return ThemeMode.dark;
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_prefsKey);
    if (stored != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == stored,
        orElse: () => ThemeMode.dark,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}

final NotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
